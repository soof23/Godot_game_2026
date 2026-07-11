extends Control

var playing: bool = false
var finished: bool = false
var typewriter_tween: Tween

@onready var v_box_container: VBoxContainer = $play/VBoxContainer
@onready var click: GPUParticles2D = $main/click
@onready var click_p: GPUParticles2D = $play/clickP
@onready var click_s: GPUParticles2D = $sound/clickS
@onready var click_t: GPUParticles2D = $tutorial/clickT
@onready var clickSound: AudioStreamPlayer2D = $clickSound
@onready var music: AudioStreamPlayer2D = $music
@onready var typewriter: AudioStreamPlayer2D = $typewriter

func _ready() -> void:
	$main.visible = true
	$play.visible = false
	$sound.visible = false
	$tutorial.visible = false
	var rt_label = v_box_container.get_node("Label")
	rt_label.visible_ratio = 0.0

#main menu buttons
func _on_play_pressed() -> void:
	clickSound.play() #ηχητικό εφέ
	if not playing:
		playing = true
		click.global_position = get_global_mouse_position()
		click.restart() # particles στη θέση του κλικ
		click.emitting = true
		music.stop() #σταματάει μουσική μενού
		await get_tree().create_timer(0.5).timeout 
		typewriter.play() #ξεκινάει ήχος γραφομηχανής
		$main.visible = false
		$play.visible = true
		$sound.visible = false
		$tutorial.visible = false
		await get_tree().create_timer(0.5).timeout 
		show_typewriter_message() #εμφάνιση ιστορίας

func _on_sound_pressed() -> void:
	clickSound.play()
	playing = false
	click.global_position = get_global_mouse_position()
	click.restart()
	click.emitting = true
	await get_tree().create_timer(0.5).timeout 
	$main.visible = false
	$play.visible = false
	$sound.visible = true
	$tutorial.visible = false

func _on_tutorial_pressed() -> void:
	clickSound.play()
	playing = false
	click.global_position = get_global_mouse_position()
	click.restart()
	click.emitting = true
	await get_tree().create_timer(0.5).timeout 
	$main.visible = false
	$play.visible = false
	$sound.visible = false
	$tutorial.visible = true

#play buttons
func _on_start_pressed() -> void:
	if finished == true:
		clickSound.play()
		click_p.global_position = get_global_mouse_position()
		click_p.restart()
		click_p.emitting = true
		await get_tree().create_timer(0.5).timeout 
		GameState.level += 1 #αρχή παιχνιδιού
		GameState.start_game()

func _on_play_back_pressed() -> void:
	clickSound.play()
	click_p.global_position = get_global_mouse_position()
	click_p.restart()
	click_p.emitting = true
	if typewriter_tween:
		typewriter_tween.kill()
	typewriter.stop()
	playing = false 
	await get_tree().create_timer(0.5).timeout 
	music.play()
	$main.visible = true
	$play.visible = false
	$sound.visible = false
	$tutorial.visible = false

func _on_skip_pressed() -> void:
	if finished:
		return
	clickSound.play()
	click_p.global_position = get_global_mouse_position()
	click_p.restart()
	click_p.emitting = true
	
	if typewriter_tween:
		typewriter_tween.kill()
	typewriter.stop()
	
	var rt_label = v_box_container.get_node("Label")
	rt_label.visible_characters = -1
	finished = true

#sound buttons
func _on_mute_pressed() -> void:
	clickSound.play()
	click_s.global_position = get_global_mouse_position()
	click_s.restart()
	click_s.emitting = true
	await get_tree().create_timer(0.5).timeout 
	# mute όλο το παιχνίδι από το κεντρικό κανάλι
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true) 

func _on_unmute_pressed() -> void:
	clickSound.play()
	click_s.global_position = get_global_mouse_position()
	click_s.restart()
	click_s.emitting = true
	await get_tree().create_timer(0.5).timeout 
	# unmute όλο το παιχνίδι από το κεντρικό κανάλι
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)

func _on_sound_back_pressed() -> void:
	clickSound.play()
	click_s.global_position = get_global_mouse_position()
	click_s.restart()
	click_s.emitting = true
	await get_tree().create_timer(0.5).timeout 
	$main.visible = true
	$play.visible = false
	$sound.visible = false
	$tutorial.visible = false

#tutorial buttons
func _on_tutorial_back_pressed() -> void:
	clickSound.play()
	click_t.global_position = get_global_mouse_position()
	click_t.restart()
	click_t.emitting = true
	await get_tree().create_timer(0.5).timeout 
	$main.visible = true
	$play.visible = false
	$sound.visible = false
	$tutorial.visible = false


func show_typewriter_message():
	if typewriter_tween:
		typewriter_tween.kill()
	
	finished = false
	var rt_label = v_box_container.get_node("Label")
	# κείμενο της ιστορίας του παιχνιδιού
	var full_text = "A dark curse is spreading across the world, bleaching the colors of nature and silencing its melodies. The Sacred Flower, the heartbeat of our world, is withering inside the Ancient Temple. As the last witch of your tribe, you must succeed where all others failed. Cross the dangerous forest, gather the essence of life from the remaining mushrooms and reach the flower before time runs out. Otherwise, the world will fall into eternal silence and darkness. The fate of the world now rests in your hands. You are our only hope for The Last Bloom."
	rt_label.text = full_text
	rt_label.visible_characters = 0
	var total_chars = full_text.length() #συνολικό πλήος χαρακτήρων
	var duration = total_chars * 0.08    #0.08 δευτερολεπτα / χαρακτήρα
	
	typewriter_tween = create_tween()
	typewriter_tween.tween_method(
		func(next_char): 
			if rt_label.visible_characters != next_char:
				rt_label.visible_characters = next_char #εμφανίζει επόμενο χαρακτήρα
				play_typewriter_sfx(full_text, next_char) #και παίζει ηχητικό εφέ
			, 0, total_chars, duration
	)
	await typewriter_tween.finished 
	finished = true

func play_typewriter_sfx(text_string, current_char_idx):
	if not playing: 
		return
	if current_char_idx <= 0 or current_char_idx > text_string.length():
		return
	var current_char = text_string[current_char_idx - 1] #1 χαρακτήρας
	
	# παράγεται ήχος γραφομηχανής μόνο αν δεν είναι κενό ή αλλαγή γραμμής
	if current_char != " " and current_char != "\n":
		typewriter.pitch_scale = randf_range(0.85, 1.15) #τυχαία αυξομείωση τόνου
		typewriter.volume_db = randf_range(-2.0, 2.0) #τυχαία αυξομείωση έντασης
		typewriter.play()

# κουμπί quit
func _on_quit_pressed() -> void:
	clickSound.play()
	get_tree().quit()
