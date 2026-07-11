extends Control

@onready var time: Label = $CanvasLayer/VBoxContainer/VBoxContainer/Time
@onready var damages: Label = $CanvasLayer/VBoxContainer/VBoxContainer/Damages
@onready var crystals: Label = $CanvasLayer/VBoxContainer/VBoxContainer/Crystals
@onready var click: GPUParticles2D = $click
@onready var click_sound: AudioStreamPlayer2D = $clickSound
@onready var flower: Node2D = $flower/AnimatedSprite2D
@onready var fade: ColorRect = $CanvasLayer/Fade
@onready var gold: GPUParticles2D = $CanvasLayer/Gold
@onready var music: Node2D = $Music

func _ready() -> void:
	music.get_node_or_null("2").play() 
	update_dynamic_music() #διαχείριση μουσικής
	
	# μετατροπή χρόνου για στατιστικά
	var total_seconds = int(GameState.time_taken)
	var minutes = total_seconds / 60
	var seconds = total_seconds % 60
	
	# στατιστικά
	time.text = "Time:  %02d:%02d" % [minutes, seconds]
	damages.text = "Damages:  " + str(GameState.total_damages)
	crystals.text = "Crystals:  " + str(GameState.total_crystals)
	
	flower.play("win")
	flower.material.set_shader_parameter("pulse_speed", 5.0)
	flower.material.set_shader_parameter("pulse_intensity", 0.07)
	
	# fade in εφε
	fade.modulate.a = 1.0
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 0.0, 1.5)
	await tween.finished

# ανοίγει όλα τα streams ήχου 
# ακούγονται όλοι οι ήχοι της φύσης που εμφανίζονταν ένας ένας από την 2η πίστα
func update_dynamic_music() -> void:
	var sync = music.get_node_or_null("2")
	if not sync or not sync.stream is AudioStreamSynchronized:
		return
	var sync_stream = sync.stream as AudioStreamSynchronized
	sync_stream.set_sync_stream_volume(1, 0.0)
	sync_stream.set_sync_stream_volume(2, 0.0)
	sync_stream.set_sync_stream_volume(3, 0.0)
	sync_stream.set_sync_stream_volume(4, 0.0)

# κουμπί play again
func _on_button_pressed() -> void:
	click_sound.play()
	click.global_position = get_global_mouse_position()
	click.restart()
	click.emitting = true
	await get_tree().create_timer(0.8).timeout 
	GameState.reset()

# κουμπί quit
func _on_button_2_pressed() -> void:
	click_sound.play()
	get_tree().quit()
