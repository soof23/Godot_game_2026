extends Control

@onready var click: GPUParticles2D = $click
@onready var game_over_sound: AudioStreamPlayer2D = $gameOverSound
@onready var click_sound: AudioStreamPlayer2D = $clickSound
@onready var fade: ColorRect = $CanvasLayer/Fade

func _ready() -> void:
	fade.modulate.a = 1.0 #ξεκινάει απο μαύρο για fade in
	game_over_sound.play() #ηχητικό εφέ gameover και μετά σιωπή γιατί χάθηκαν οι ήχοι 
	var tween = create_tween() #tween για ομαλό fade in
	tween.tween_property(fade, "modulate:a", 0.0, 1.5)
	await tween.finished

# κουμπί play again
func _on_button_pressed() -> void:
	click_sound.play() #ηχητικό εφέ κλικ
	click.global_position = get_global_mouse_position()
	click.restart() #εφέ κλικ με particles
	click.emitting = true
	await get_tree().create_timer(0.5).timeout 
	GameState.reset()

# κουμπί quit
func _on_button_2_pressed() -> void:
	click_sound.play()
	get_tree().quit()
