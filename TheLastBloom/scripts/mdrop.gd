extends Area2D

signal taken

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var collected_sound: AudioStreamPlayer2D = $CollectedSound

func _on_body_entered(_body: Node2D) -> void:
	if animated_sprite_2d.animation == "drop":
		animated_sprite_2d.play("drop_collected") #animation συλλογής
		if collected_sound:
			collected_sound.play() #ηχητικό εφέ
		taken.emit() #στλενει σήμα για να ενημερωθεί το πλήθος των σταγόνων
		collision_shape_2d.set_deferred("disabled", true)

func _on_animated_sprite_2d_animation_finished() -> void:
	if animated_sprite_2d.animation == "drop_collected":
		queue_free()
