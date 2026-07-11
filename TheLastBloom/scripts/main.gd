extends Node2D

@onready var heart: Control = $CanvasLayer/Control/VBoxContainer/heart
@onready var potion: Control = $CanvasLayer/Control/VBoxContainer/potion
@onready var fade: ColorRect = $CanvasLayer/Fade
@onready var timer: Timer = $Timer
@onready var message_w: VBoxContainer = $CanvasLayer/Control/messageW
@onready var message_1: VBoxContainer = $CanvasLayer/Control/message1
@onready var message_p: VBoxContainer = $CanvasLayer/Control/messageP
@onready var message_4: VBoxContainer = $CanvasLayer/Control/message4
@onready var pause_menu: Panel = $CanvasLayer/PauseMenu
@onready var lasttimer: Control = $CanvasLayer/Control/VBoxContainer/lasttimer
@onready var last_timer: Timer = $LastTimer
@onready var click_sound: AudioStreamPlayer2D = $clickSound
@onready var gold: GPUParticles2D = $CanvasLayer/Gold
@onready var music: Node2D = $Music
@onready var shieldtimer: Control = $CanvasLayer/Control/VBoxContainer/shieldtimer
@onready var shield_timer: Timer = $ShieldTimer
@onready var countdown_sound: AudioStreamPlayer2D = $countdownSound
@onready var lighttimer: Control = $CanvasLayer/Control/VBoxContainer/lighttimer
@onready var light_timer: Timer = $LightTimer

var current_level_root: Node = null
var paused: bool = false
var labelT
var bloom
var shaking_bloom: bool = false
var level3_music: bool = false
var shield_tween: Tween
var countdown_started: bool = false
var end: bool = false

func _ready() -> void:
	# επαναφορά αν έρχεται από play again
	last_timer.stop()
	end = false
	countdown_started = false
	
	if GameState.level == 0:
		call_deferred("startmenu")  #αρχικό μενού
	elif GameState.level < 4:
		fade.modulate.a = 1.0  #fade in
		var label = heart.get_node_or_null("Label")
		label.text = str(GameState.player_health)
		var labelD = potion.get_node_or_null("Label")
		labelD.text = str(GameState.drops)
		current_level_root = get_node("LevelRoot")
		await _load_level(GameState.level, true)

func _process(_delta: float) -> void:
	if GameState.level == 0:
		call_deferred("startmenu")
	
	if GameState.player_health == 0:
		if music:
			music.queue_free()
		await get_tree().create_timer(1.0).timeout 
		game_over() #μετάβαση στην οθόνη Game Over
	
	# pause menu
	if Input.is_action_just_pressed("pause"):
		pause_play()
		get_tree().paused = paused
	
	if GameState.level == 3 and GameState.limit_level3 == false and not level3_music:
		openmusic() #αν πέρασε την θύελλα, ξεκινάει η μουσική
	elif GameState.level == 3 and GameState.limit_level3 == true:
		level3_music = false
		if Input.is_action_just_pressed("shield_rain") and !GameState.is_shielding:
			# ξεκινάει η ασπίδα
			start_shield_timer()
	
	if GameState.level == 4:
		# δείχνει τα δευτερόλεπτα που απομένουν στην οθόνη
		labelT = lasttimer.get_node_or_null("time")
		labelT.text = str(int(last_timer.time_left))
		#αλλάζει την ταχύτητα του shader ανάλογα με τον χρόνο
		if last_timer.time_left < 10.0:
			labelT.material.set_shader_parameter("speed", 7.0)
		elif last_timer.time_left < 30.0:
			labelT.material.set_shader_parameter("speed", 5.0)
		else:
			labelT.material.set_shader_parameter("speed", 3.0)
		
		# δυναμικός ήχος: αυξάνει την ένταση όσο ο παίκτης πλησιάζει το λουλούδι
		var sync_player = music.get_node_or_null("2")
		var sync_stream = sync_player.stream as AudioStreamSynchronized
		var flower = current_level_root.get_node_or_null("flower") 
		var player = current_level_root.get_node_or_null("Player")
		if sync_player and flower and player:
			var dist = player.global_position.distance_to(flower.global_position)
			var max_dist = 1000.0
			var volume = remap(clamp(dist, 0, max_dist), 0, max_dist, 0.0, -30.0)
			sync_stream.set_sync_stream_volume(4, volume)
		
		# εφέ ήχου countdown στα τελευταία 10 δευτερόλεπτα
		var time_left = last_timer.time_left
		if time_left <= 10.0 and time_left > 0 and not countdown_started:
			countdown_sound.play()
			countdown_started = true
		if time_left <= 0 or GameState.level != 4:
			countdown_sound.stop()
			countdown_started = false

# διαχείριση πίστας
func _load_level(level_number: int, first_load: bool) -> void:
	#fade out
	if not first_load:
		await _fade(1.0)
	
	if current_level_root:
		current_level_root.queue_free()
	
	# instantiate τη σκηνή του νέου level 
	var level_path = "res://scenes/levels/level%s.tscn" % level_number
	current_level_root = load(level_path).instantiate()
	add_child(current_level_root)
	current_level_root.name = "LevelRoot"
	
	# μουσική ανάλογα με το level
	if level_number == 1:
		music.get_node_or_null(str(level_number)).play()
	if level_number == 2:
		music.get_node_or_null(str(level_number-1)).stop()
		music.get_node_or_null(str(level_number)).play()
	if level_number == 3 and GameState.limit_level3 == true:
		# σταματάει η μουσική λόγω της θύελλας
		music.get_node_or_null("2").stop()
	if level_number == 4:
		var sync_player = music.get_node("2")
		var sync_stream = sync_player.stream as AudioStreamSynchronized
		sync_stream.set_sync_stream_volume(4, -30.0)
	
	# ένταση των ηχητικών εφέ ανάλογα με την πίστα
	var final_sfx_bus = AudioServer.get_bus_index("SFX_FINAL")
	if level_number == 1:
		AudioServer.set_bus_volume_db(final_sfx_bus, -10.0)
	else:
		AudioServer.set_bus_volume_db(final_sfx_bus, 0.0)
	
	# εφέ reverb στον ναό 
	if level_number == 4:
		setup_temple_reverb(true)
	else:
		setup_temple_reverb(false)
	
	lasttimer.visible = false
	
	# εμφάνιση μηνυμάτων
	if level_number == 2:
		showLevel2Mess()
	if level_number == 3:
		showLevel3Mess()
	if level_number == 4:
		lasttimer.visible = true
		heart.visible = false
		potion.get_node_or_null("Label").visible = false
		last_timer.start() #αντίστροφη μέτρηση
		labelT = lasttimer.get_node_or_null("time")
		labelT.text = str(int(last_timer.time_left))
		showLevel4Mess();
		
	_setup_level(current_level_root)
	await _fade(0.0) #fade in

# σύνδεση signals των αντικειμένων της πίστας
func _setup_level(level_root: Node) -> void:
	#έξοδος σε επόμενη πίστα ή νίκη
	var exit = level_root.get_node_or_null("Exit")
	if exit: 
		exit.body_entered.connect(_on_exit_body_entered)
	
	if GameState.level == 4:
		bloom = level_root.get_node_or_null("flower")
	
	#κρύσταλλοι ζωής
	var crystals = level_root.get_node_or_null("crystals")
	if crystals:
		for crystal in crystals.get_children():
			crystal.collected.connect(increase_health)
	
	#εχθροί
	var enemies = level_root.get_node_or_null("enemies")
	if enemies:
		for enemy in enemies.get_children():
			enemy.player_died.connect(_on_player_died)
	
	#καρφιά εδάφους
	var spikes = level_root.get_node_or_null("spikes")
	if spikes:
		for spike in spikes.get_children():
			spike.player_die.connect(_on_player_died)
	
	#παίκτης
	var player = level_root.get_node_or_null("Player")
	if player:
		player.enemy_died.connect(_on_enemy_died)
	
	#μανιτάρια-σταγόνες
	var mdrops = level_root.get_node_or_null("mDrops")
	if mdrops:
		for drop in mdrops.get_children():
			drop.taken.connect(fill_bottle)
	
	#καρφιά από αέρα
	if GameState.level == 3:
		var fallingspikes = level_root.get_node_or_null("fallingspikes")
		if fallingspikes:
			for fallingspike in fallingspikes.get_children():
				fallingspike.player_die.connect(_on_player_died)

# επαφή με αντικείμενο επόμενης πίστας
func _on_exit_body_entered(body: Node2D) -> void:
	if GameState.level == 1:
		if body.name == "Player"  and GameState.drops == 2:
			body.play_exit()
			_transition_audio_effect()
			GameState.level += 1
			#GameState.time_taken += 900 - int(timer.time_left)
			_load_level(GameState.level, false)
		else:
			showPotionMess()
	elif GameState.level == 2 :
		if body.name == "Player"  and GameState.drops == 5:
			body.play_exit()
			_transition_audio_effect()
			GameState.level += 1
			#GameState.time_taken += 900 - int(timer.time_left)
			_load_level(GameState.level, false)
		else:
			showPotionMess()
	elif GameState.level == 3 :
		if body.name == "Player"  and GameState.drops == 7:
			body.play_exit()
			_transition_audio_effect() 
			GameState.level += 1
			#GameState.time_taken += 900 - int(timer.time_left)
			_load_level(GameState.level, false)
		else:
			showPotionMess()
	elif GameState.level == 4 :
		if body.name == "Player":
			end = true
			var player = body
			player.can_move = false 
			player.get_node_or_null("AnimatedSprite2D").play("idle")
			player.velocity = Vector2.ZERO
			var push_distance = 10.0
			var target_x = player.global_position.x
			if player.global_position.x < bloom.global_position.x:
				target_x -= push_distance
			else:
				target_x += push_distance
			var push_tween = create_tween()
			push_tween.tween_property(player, "global_position:x", target_x, 0.4)\
						.set_trans(Tween.TRANS_QUAD)\
						.set_ease(Tween.EASE_OUT)
			push_tween.parallel().tween_property(player, "global_position:y", player.global_position.y - 5, 0.2)\
						.set_trans(Tween.TRANS_SINE)\
						.set_ease(Tween.EASE_OUT)
			push_tween.tween_property(player, "global_position:y", player.global_position.y, 0.2)\
						.set_trans(Tween.TRANS_SINE)\
						.set_ease(Tween.EASE_IN)
			
			# shader λουλουδιού
			var screen_pos = player.get_global_transform_with_canvas().origin
			var sprite = bloom.get_node("AnimatedSprite2D")
			sprite.material.set_shader_parameter("pulse_speed", 5.0)
			sprite.material.set_shader_parameter("pulse_intensity", 0.07)
			await get_tree().create_timer(0.2).timeout
			# το λουλούδι ανθίζει
			bloom.get_node_or_null("AnimatedSprite2D").play("bloom")
			player.get_node_or_null("trail").visible = false
			
			# χρυσά particles γύρης
			gold.global_position = screen_pos
			gold.restart()
			gold.emitting = true
			var camera = get_viewport().get_camera_2d()
			if camera:
				shake_screen(camera, 1.0, 3.0)
			await get_tree().create_timer(0.2).timeout
			call_deferred("gamewon")

func _on_player_died(body):
	body.die()

func _on_enemy_died(body):
	body.die()

func increase_health() -> void:
	update_player_health(1)
	GameState.total_crystals += 1

# Life
func update_player_health(amount: int) -> void:
	var label = heart.get_node_or_null("Label")
	GameState.player_health = clamp(GameState.player_health + amount, GameState.min_health, GameState.max_health)
	label.text = str(GameState.player_health)
	if GameState.player_health > 0 :
		heart.get_node_or_null("AnimatedSprite2D").play(str(GameState.player_health))

# συλλογή σταγόνων
func fill_bottle() -> void:
	GameState.drops += 1
	var labelD = potion.get_node_or_null("Label")
	labelD.text = str(GameState.drops)
	#αλλάζει το animation του UI του μπουκαλιού ανάλογα με την ποσότητα
	if GameState.drops < 4:
		potion.get_node_or_null("AnimatedSprite2D").play(str(GameState.drops))
	elif GameState.drops < 6:
		potion.get_node_or_null("AnimatedSprite2D").play(str(GameState.drops - 1))
	elif GameState.drops < 8:
		potion.get_node_or_null("AnimatedSprite2D").play("5")
	
	#ενημερώνει με Tween το fill_amount του shader, όσο γεμίζει όλο και πιο λαμπερό
	var sprite = potion.get_node_or_null("AnimatedSprite2D")
	if sprite and sprite.material is ShaderMaterial:
		var fill_ratio = float(GameState.drops) / 7.0
		var tween = create_tween()
		tween.tween_property(sprite.material, "shader_parameter/fill_amount", fill_ratio, 0.4)
	update_dynamic_music() #ενεργοποιεί κανάλια μουσικής

func game_over():
	await _fade(1.0)
	get_tree().change_scene_to_file("res://scenes/gameover.tscn")

func gamewon():
	GameState.time_taken = int(timer.wait_time - timer.time_left)
	await _fade(1.0)
	get_tree().change_scene_to_file("res://scenes/gamewon.tscn")

func startmenu():
	get_tree().change_scene_to_file("res://scenes/startmenu.tscn")

# εφέ fade με Tween για το alpha του ColorRect
func _fade(to_alpha: float) -> void:
	var tween := create_tween()
	tween.tween_property(fade, "modulate:a", to_alpha, 1.5)
	await tween.finished


# Εμφάνιση Μηνυμάτων
func showLevel2Mess()->void:
	click_sound.play()
	message_w.modulate.a = 1.0
	message_w.visible = true
	await get_tree().create_timer(7.0).timeout
	var tween = create_tween()
	tween.tween_property(message_w, "modulate:a", 0.0, 1.0) # Fade out σε 1 δευτερόλεπτο
	await tween.finished
	message_w.visible = false

func showLevel3Mess()->void:
	click_sound.play()
	message_1.modulate.a = 1.0
	message_1.visible = true
	await get_tree().create_timer(7.0).timeout
	var tween = create_tween()
	tween.tween_property(message_1, "modulate:a", 0.0, 1.0) # Fade out σε 1 δευτερόλεπτο
	await tween.finished
	message_1.visible = false

func showLevel4Mess()->void:
	click_sound.play()
	message_4.modulate.a = 1.0
	message_4.visible = true
	await get_tree().create_timer(7.0).timeout
	var tween = create_tween()
	tween.tween_property(message_4, "modulate:a", 0.0, 1.0) # Fade out σε 1 δευτερόλεπτο
	await tween.finished
	message_4.visible = false

func showPotionMess()->void:
	# μήνυμα ότι η πύλη είναι κλειδωμένη αν δεν έχει μαζέψει τις απαραίτητες σταγόνες
	if !GameState.drops == 2 and !GameState.drops == 5 and !GameState.drops == 7 :
		click_sound.play()
		message_p.modulate.a = 1.0
		message_p.visible = true
		await get_tree().create_timer(7.0).timeout
		var tween = create_tween()
		tween.tween_property(message_p, "modulate:a", 0.0, 1.0) # Fade out σε 1 δευτερόλεπτο
		await tween.finished
		message_p.visible = false

#Pause Menu
func pause_play()->void:
	paused = !paused
	pause_menu.visible = paused
func _on_resume_pressed() -> void:
	get_tree().paused = false
	pause_play()
func _on_restart_pressed() -> void:
	get_tree().paused = false
	GameState.reset()
func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	GameState.restart()


func _on_last_timer_timeout() -> void:
	game_over() #αν τελειώσει ο χρόνος στο Level 4 ο παίκτης χάνει

func openmusic()->void:
	var m3 = music.get_node_or_null("2")
	if m3 and not m3.playing:
		m3.play() #ξεκινάει τη μουσική της 3ης πίστας μετά τον αέρα
		level3_music = true

# εφέ shake screen
func shake_screen(camera: Camera2D, duration: float, intensity: float):
	var original_offset = camera.offset
	var elapsed_time = 0.0
	while elapsed_time < duration:
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity))
		camera.offset = original_offset + shake_offset
		elapsed_time += get_process_delta_time()
		await get_tree().process_frame 
	camera.offset = original_offset

# Ασπίδα αέρα
func start_shield_timer():
	GameState.is_shielding = true
	shieldtimer.visible = true
	update_shield_audio(true)  #φίλτρα στον ήχο όσο η ασπίδα ενεργή 
	shield_timer.start() #αντίστροφη μέτρηση
	labelT = shieldtimer.get_node_or_null("time")
	labelT.material.set_shader_parameter("speed", 7.0) #ο χρόνος φαίνεται στην οθόνη
	while shield_timer.time_left > 0 and GameState.is_shielding == true:
		labelT.text = str(int(shield_timer.time_left))
		await get_tree().process_frame
	shieldtimer.visible = false
	GameState.is_shielding = false
	update_shield_audio(false) #επαναφορά ήχου

# δυναμικό φίλτρο ήχου
# όταν ο παίκτης χρησιμοποιεί την ασπίδα, ο ήχος της θύελλας παραμορφώνεται
func update_shield_audio(is_shield_active: bool):
	var bus_idx = AudioServer.get_bus_index("air")
	var filter = AudioServer.get_bus_effect(bus_idx, 0) as AudioEffectLowPassFilter
	var distortion = AudioServer.get_bus_effect(bus_idx, 1) as AudioEffectDistortion
	
	if shield_tween:
		shield_tween.kill()
	shield_tween = create_tween().set_parallel(true)
	
	if is_shield_active:
		shield_tween.tween_property(filter, "cutoff_hz", 600.0, 0.3) 
		shield_tween.tween_method(func(vol): AudioServer.set_bus_volume_db(bus_idx, vol), 
			AudioServer.get_bus_volume_db(bus_idx), -12.0, 0.3)
		shield_tween.tween_property(distortion, "drive", 0.4, 0.3)
	else: # επαναφορά
		shield_tween.tween_property(filter, "cutoff_hz", 20000.0, 0.5)
		shield_tween.tween_method(func(vol): AudioServer.set_bus_volume_db(bus_idx, vol), 
			AudioServer.get_bus_volume_db(bus_idx), 0.0, 0.5)
		shield_tween.tween_property(distortion, "drive", 0.0, 0.5)

# AudioStreamSynchronized 
# ανάλογα με τις σταγόνες ενεργοποιούνται/δυναμώνουν νέες μελωδίες
func update_dynamic_music() -> void:
	var sync_player = music.get_node_or_null("2")
	if not sync_player or not sync_player.stream is AudioStreamSynchronized:
		return
	var sync_stream = sync_player.stream as AudioStreamSynchronized
	match GameState.drops:
		3:
			sync_stream.set_sync_stream_volume(1, -12.0)
		4:
			sync_stream.set_sync_stream_volume(2, 0.0)
		5:
			sync_stream.set_sync_stream_volume(1, 0.0)
		6:
			sync_stream.set_sync_stream_volume(3, -12.0)
		7:
			sync_stream.set_sync_stream_volume(3, 0.0)

# αντήχηση-reverb του ναού
func setup_temple_reverb(active: bool)->void:
	var master_bus = AudioServer.get_bus_index("Master")
	var effect_index = 1
	if AudioServer.get_bus_effect(master_bus, effect_index) is AudioEffectReverb:
		AudioServer.set_bus_effect_enabled(master_bus, effect_index, active)

# εφέ κατά τη μετάβαση πιστών
func _transition_audio_effect() -> void:
	var master_bus = AudioServer.get_bus_index("Master")
	var audio_tween = create_tween().set_parallel(true)
	
	audio_tween.tween_method(func(p): Engine.time_scale = p, 1.0, 1.4, 1.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	AudioServer.set_bus_effect_enabled(master_bus, 1, true)
	
	audio_tween.tween_method(func(vol): AudioServer.set_bus_volume_db(master_bus, vol), 0.0, 6.0, 1.0)
	
	AudioServer.set_bus_effect_enabled(master_bus, 1, true)
	var reverb_effect = AudioServer.get_bus_effect(master_bus, 1) as AudioEffectReverb
	if reverb_effect:
		audio_tween.tween_property(reverb_effect, "wet", 0.8, 1.0)
	await audio_tween.finished
	
	# επαναφορά ρυθμίσεων ήχου
	var reset_tween = create_tween().set_parallel(true)
	reset_tween.tween_method(func(p): Engine.time_scale = p, 1.1, 1.0, 0.5)
	reset_tween.tween_method(func(vol): AudioServer.set_bus_volume_db(master_bus, vol), 4.0, 0.0, 1.0)
	
	if GameState.level != 4:
		# αν δεν είναι στην πίστα του ναού κλείνει το reverb
		await get_tree().create_timer(1.0).timeout
		AudioServer.set_bus_effect_enabled(master_bus, 1, false)

# αντίστροφη μέτρηση στην οθόνη για το ξόρκι του φωτός
func start_light_countdown(duration: float):
	if !end:
		lighttimer.visible = true
		light_timer.wait_time = duration
		light_timer.start()
		var timer_label = lighttimer.get_node("time")
		
		var canvas_modulate = current_level_root.get_node_or_null("ParallaxBackground/CanvasModulate")
		var start_color = Color(0.19, 0.19, 0.19, 1.0)
		var end_color = Color(0.293, 0.293, 0.293, 1.0)
		
		while is_inside_tree() and light_timer.time_left > 0:
			timer_label.text = str(int(light_timer.time_left) + 1)
			
			if canvas_modulate:
				canvas_modulate.color = end_color
			
			await get_tree().process_frame
			if not is_inside_tree(): 
				return
		if is_inside_tree():
			lighttimer.visible = false
			if canvas_modulate:
				canvas_modulate.color = start_color
