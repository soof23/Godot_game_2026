extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -500.0

var alive = true
var jump_count = 0
var was_in_air: bool = false
var vector: Vector2 = Vector2(0.0,0.0)
var can_move: bool = true

@export var max_jump = 2  #μέγιστος αριθμός αλμάτων
@export var mushroom_range: float = 160.0  #εύρος που μπορεί να στοχεύσει μανιτάρια
@export var enemy_range: float = 160.0   #εύρος που μπορεί να χτυπήσει εχθρούς
@export var height_tolerance: float = 80.0  #μέγιστη υψομετρική διαφορά για στόχευση

@onready var spell: Node2D = $spell
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var animation_player_hurting: AnimationPlayer = $AnimationPlayerHurting
@onready var jump_sound: AudioStreamPlayer2D = $sounds/jumpSound
@onready var hit_sound: AudioStreamPlayer2D = $sounds/hitSound
@onready var mushroom_spell: AudioStreamPlayer2D = $sounds/mushroomSpell
@onready var death_sound: AudioStreamPlayer2D = $sounds/deathSound
@onready var main: Node2D = $"../.."   #για τη main σκηνή
@onready var trail: GPUParticles2D = $trail  #particles που αφήνει πίσω του ο παίκτης τρέχοντας
@onready var land_stone: AudioStreamPlayer2D = $sounds/landStone #ήχος προσγείωσης σε πέτρα
@onready var land_grass: AudioStreamPlayer2D = $sounds/landGrass  #ήχος προσγείωσης σε γρασίδι
@onready var shield_sprite: Sprite2D = $ShieldSprite #η ασπίδα αέρα από τον shader
@onready var spell_light: PointLight2D = $LightSpell #2d φως για το ξόρκι δυναμικού φωτισμού
@onready var light_sound: AudioStreamPlayer2D = $sounds/LightSound

signal enemy_died  #εκπέμπεται όταν ο παίκτης σκοτώνει εχθρό

func _ready() -> void:
	can_move = true
	trail.visible = true
	update_trail_color() #ρυθμίζει χρώμα particles ανάλογα με την πίστα
	
	#fade in εφέ στην αρχή της πίστας
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	await tween.finished

func _physics_process(delta: float) -> void:
	if is_on_floor():
		jump_count = 0
		if was_in_air :
			#εφέ σκόνης προσγείωσης
			PlayerEffects.land_dust(global_position + vector)
			# ηχητικό εφέ ανάλογα με το έδαφος
			if GameState.level == 1 or GameState.level == 4:
				land_stone.play()
			else:
				land_grass.play()
			was_in_air = false
	else: 
		was_in_air = true
	
	# βαρύτητα
	if not is_on_floor() and alive:
		velocity += get_gravity() * delta
	
	# ασπίδα αέρα
	if GameState.level == 3 and GameState.limit_level3 == true:
		shield_sprite.visible = GameState.is_shielding
	else:
		shield_sprite.visible = false
	
	if alive and can_move:
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor() and jump_count < max_jump:
			jump_count += 1
			velocity.y = JUMP_VELOCITY
			jump_sound.play()
			PlayerEffects.jump_dust(global_position) #εφέ σκόνης άλματος
		
		# double jump
		if Input.is_action_just_pressed("jump") and !is_on_floor() and jump_count < max_jump and GameState.level >= 2:
			jump_count +=1
			velocity.y = JUMP_VELOCITY * 1.1
			jump_sound.play()
		
		# left key = -1 , right key = 1 , no key = 0
		var direction := Input.get_axis("move_left", "move_right")
		if direction == 1.0:
			animated_sprite_2d.scale.x = 1
			$CollisionShape2D.position.x = -10.0
			vector = Vector2(-10.0, 0.0)
			trail.position.x = -30
		elif direction == -1.0:
			animated_sprite_2d.scale.x = -1
			$CollisionShape2D.position.x = 10.0
			vector = Vector2(10.0, 0.0)
			trail.position.x = 30
			
		# animations
		var target_mushroom = get_m_target()
		var target_enemy = get_e_target()
		if Input.is_action_pressed("hit_mushroom") and target_mushroom!= null:
			if global_position.x < target_mushroom.global_position.x :
				animated_sprite_2d.scale.x = 1
			else:
				animated_sprite_2d.scale.x=-1
			animated_sprite_2d.play("spell")
			spell.is_active = true
			spell.target = target_mushroom
			spell.get_node_or_null("AnimatedSprite2D").play("mushroom")
			mushroom_spell.play()
			await get_tree().create_timer(0.5).timeout
			var mush_sprite = target_mushroom.get_node_or_null("AnimatedSprite2D")
			mush_sprite.play("drop")
			mush_sprite.scale = Vector2(7.0,7.0)
		elif Input.is_action_pressed("hit_enemy") and target_enemy!=null:
			if global_position.x < target_enemy.global_position.x :
				animated_sprite_2d.scale.x = 1
			else:
				animated_sprite_2d.scale.x=-1
			animated_sprite_2d.play("spell")
			spell.is_active = true
			spell.target = target_enemy
			spell.get_node_or_null("AnimatedSprite2D").play("enemy")
			emit_signal("enemy_died", target_enemy)
		elif GameState.is_shielding and GameState.level == 3 and GameState.limit_level3 == true:
			if position.x >= 488.0:
				GameState.limit_level3 = false
				GameState.is_shielding = false
				shield_sprite.visible = false
			if !direction == 0:
				animated_sprite_2d.play("runAir")
				trail.emitting = true
			else:
				trail.emitting = false
				animated_sprite_2d.play("idle")
		elif Input.is_action_just_pressed("dynamic_light") and not spell_light.enabled:
			activate_spell_light()
		else:
			spell.is_active = false
			if is_on_floor():
				if (direction == 0 and !GameState.level == 3) or (direction == 0 and GameState.level == 3 and GameState.limit_level3 == false):
					animated_sprite_2d.play("idle")
					trail.emitting = false
				elif direction == 0 and GameState.level == 3 and GameState.limit_level3 == true:
					animated_sprite_2d.play("idleAir")
					trail.emitting = false
				else:
					trail.emitting = true
					if GameState.level == 3 and GameState.limit_level3 == true:
						animated_sprite_2d.play("runAir")
					else:
						animated_sprite_2d.play("run")
			else:
				animated_sprite_2d.play("jump")
		
		if !GameState.level == 3:
			if direction:
				velocity.x = direction * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		else:
			if GameState.limit_level3 == true and !GameState.is_shielding:
				#αν δεν έχει ασπίδα ο αέρας τον σπρώχνει πίσω και κινείται πολύ αργά
				if direction:
					velocity.x = direction * SPEED / 20.0
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED/20.0)
			elif GameState.limit_level3 == true and GameState.is_shielding:
				#αν έχει ασπίδα προστατεύεται και κινείται λίγο πιο γρήγορα
				if direction:
					velocity.x = direction * SPEED / 5.0
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED/5.0)
			else:
				if direction:
					velocity.x = direction * SPEED
				else:
					velocity.x = move_toward(velocity.x, 0, SPEED)
		
		move_and_slide()

func get_m_target() -> Node2D:
	var m_drops_node = get_parent().get_node_or_null("mDrops")
	if m_drops_node:
		var mushrooms = m_drops_node.get_children()
		for mush in mushrooms:
			var dist = global_position.distance_to(mush.global_position)
			var height_diff = global_position.y - mush.global_position.y
			if dist < mushroom_range and height_diff < 50.0 and height_diff > -height_tolerance:
				return mush
		return null
	return null
func get_e_target() -> Node2D:
	var en_node = get_parent().get_node_or_null("enemies")
	if en_node:
		var enemies = en_node.get_children()
		for en in enemies:
			var dist = global_position.distance_to(en.global_position)
			var height_diff = global_position.y - en.global_position.y
			if dist < enemy_range and height_diff < 15.0 and height_diff > -height_tolerance:
				return en
		return null
	return null

# τραυματισμός / Θάνατος του παίκτη
func die() -> void:
	if !alive : return
	main.update_player_health(-1)
	GameState.total_damages += 1
	hit_sound.play()
	animation_player_hurting.play("hurting")
	$TimerHurting.start()
	$Camera2D.shake()
	if GameState.player_health == 0 :
		alive = false
		death_sound.play()
		$Camera2D.shake()
		animated_sprite_2d.animation = "dead"
		$Camera2D.shake()
		await get_tree().create_timer(1.0).timeout 

func _on_timer_hurting_timeout() -> void:
	animation_player_hurting.play("idle") #επαναφέρει τον παίκτη στην κανονική του κατάσταση

func play_exit() -> void:
	can_move = false
	velocity = Vector2.ZERO
	animated_sprite_2d.play("charge")  #animation για μεταφορά στην επόμενη πίστα
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.5, 0.5)

# αλλαγή χρωμάτων ίχνους ανάλογα με την πίστα
func update_trail_color()->void:
	var current_level = GameState.level
	var particle_material = trail.process_material as ParticleProcessMaterial
	var ramp_tex = particle_material.color_ramp as GradientTexture1D
	var initial_ramp_tex = particle_material.color_initial_ramp as GradientTexture1D
	
	match current_level:
		1:
			particle_material.color_ramp = ramp_tex
			particle_material.color_initial_ramp = null
			var grad = ramp_tex.gradient
			grad.set_colors(PackedColorArray([
				Color(0.502, 0.502, 0.502, 1.0),
				Color(0.004, 0.329, 0.373, 0.804),
				Color(0.004, 0.329, 0.373, 0.0)
			]))
		2:
			particle_material.color_ramp = ramp_tex
			particle_material.color_initial_ramp = null
			var grad = ramp_tex.gradient
			grad.set_colors(PackedColorArray([
				Color(0.0, 0.5, 1.0, 1.0), 
				Color(0.6, 0.102, 0.902, 0.808),
				Color(0.6, 0.1, 0.9, 0.0)  
			]))
		3:
			particle_material.color_ramp = ramp_tex
			particle_material.color_initial_ramp = null
			var grad = ramp_tex.gradient
			grad.set_colors(PackedColorArray([
				Color(1.0, 0.4, 0.7, 1.0),
				Color(1.0, 0.0, 0.0, 0.8),
				Color(1.0, 1.0, 0.0, 0.0) 
			]))
		4:
			particle_material.color_ramp = null
			if initial_ramp_tex:
				particle_material.color_initial_ramp = initial_ramp_tex
				var grad = initial_ramp_tex.gradient
				grad.set_colors(PackedColorArray([
					Color(1, 0, 0), Color(1, 1, 0), Color(0.0, 0.565, 0.0, 1.0), 
					Color(0.0, 0.657, 0.657, 1.0), Color(0.0, 0.0, 0.713, 1.0), Color(0.66, 0.0, 0.66, 1.0)
				])) 
	trail.restart()
	trail.emitting = true

func activate_spell_light() -> void:
	spell_light.enabled = true
	light_sound.play()
	if is_instance_valid(main):
		main.start_light_countdown(8.0)  #αντίστροφη μέτρηση 8sec
	spell_light.energy = 0.0
	spell_light.texture_scale = 0.1
	spell_light.height = 100.0 
	
	if not is_inside_tree(): return
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(spell_light, "energy", 1.8, 0.6).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(spell_light, "texture_scale", 3.0, 0.6).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(spell_light, "height", 50.0, 0.6)
	
	var main_timer = main.get_node_or_null("LightTimer") if is_instance_valid(main) else null
	
	#δυναμικό μέγεθος φωτός
	while is_inside_tree() and is_instance_valid(main_timer) and main_timer.time_left > 0:
		var pulse = sin(main_timer.time_left * 10.0) * 0.05
		spell_light.texture_scale = 3.0 + pulse
		spell_light.energy = 1.5 + (pulse * 2.0)
		spell_light.height = 50.0 + randf_range(-2.0, 2.0)
		
		await get_tree().process_frame
		if not is_inside_tree(): 
			return
		if not alive: break
	
	# όταν τελειώσει ο χρόνος το φως σβήνει με fade out
	if is_inside_tree():
		var fade_tween = create_tween().set_parallel(true)
		fade_tween.tween_property(spell_light, "energy", 0.0, 0.8)
		fade_tween.tween_property(spell_light, "texture_scale", 0.0, 0.8)
		fade_tween.tween_property(spell_light, "height", 150.0, 0.8)
		await fade_tween.finished
		if is_inside_tree():
			spell_light.enabled = false
