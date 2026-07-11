extends Node2D

@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var limited: StaticBody2D = $limited
@onready var air: Node2D = $air
@onready var enemy_2: Area2D = $enemies/enemy2
@onready var air_sound: AudioStreamPlayer2D = $airSound

var air_fading: bool = false  #fade out του ήχου

func _ready() -> void:
	if GameState.limit_level3 == true:
		camera_2d.limit_right = 1270 #περιορισμός κάμερας για να μην βλέπει ο παίκτης την υπόλοιπη πίστα
		limited.get_child(1).disabled = true
		limited.visible = false
	
	for airnode in air.get_children():
		airnode.animation = "start"
		camera_2d.shake()
	
	enemy_2.SPEED = 0.0
	air_sound.play()

func _process(_delta: float) -> void:
	if GameState.limit_level3 == true:
		create_air()
		if !GameState.is_shielding:
			camera_2d.shake() #αν ο παίκτης δεν χρησιμοποιεί την ασπίδα
	
	if GameState.limit_level3 == false:
		if limited:
			limited.visible = true # ο παίκτης συνεχίζει στην πίστα
			limited.get_child(1).set_deferred("disabled", false)
		camera_2d.limit_right = 2510
		camera_2d.limit_left = 1180
		air.visible = false #εξαφανίζεται ο αέρας
		GameState.is_shielding = false
		if air_sound and air_sound.playing and not air_fading:
			air_fading = true
			var audio_tween = create_tween()
			audio_tween.tween_property(air_sound, "volume_db", -60.0, 5.0).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			audio_tween.finished.connect(func(): air_sound.stop())

func create_air()->void:
	await  get_tree().create_timer(2.0).timeout
	var airn = air.get_child(0)
	if airn.animation == "start":
		airn.animation = "air"
		airn.position.y = 168.0
		airn.scale = Vector2(1.8,1.8)
	var airn1 = air.get_child(1)
	if airn1.animation == "start":
		airn1.animation = "air"
		airn1.position.y = 168.0
		airn1.scale = Vector2(1.8,1.8)
	var airn2 = air.get_child(2)
	if airn2.animation == "start":
		airn2.animation = "air"
		airn2.position.y = 168.0
		airn2.scale = Vector2(1.8,1.8)
	var airn3 = air.get_child(3)
	if airn3.animation == "start":
		airn3.animation = "air"
		airn3.position.y = 168.0
		airn3.scale = Vector2(1.8,1.8)
	var airn4 = air.get_child(4)
	if airn4.animation == "start":
		airn4.animation = "air"
		airn4.position.y = 168.0
		airn4.scale = Vector2(1.8,1.8)
	var airn5 = air.get_child(5)
	if airn5.animation == "start":
		airn5.animation = "air"
		airn5.position.y = 168.0
		airn5.scale = Vector2(1.8,1.8)
	var airn6 = air.get_child(6)
	if airn6.animation == "start":
		airn6.animation = "air"
		airn6.position.y = 168.0
		airn6.scale = Vector2(1.8,1.8)
	var airn7 = air.get_child(7)
	if airn7.animation == "start":
		airn7.animation = "air"
		airn7.position.y = 168.0
		airn7.scale = Vector2(1.8,1.8)
	var airn8 = air.get_child(8)
	if airn8.animation == "start":
		airn8.animation = "air"
		airn8.position.y = 168.0
		airn8.scale = Vector2(1.8,1.8)
