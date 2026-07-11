extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collected_sound: AudioStreamPlayer2D = $CollectedSound
@onready var collision_polygon_2d: CollisionPolygon2D = $CollisionPolygon2D

signal collected

func _on_body_entered(_body: Node2D) -> void:
	animated_sprite_2d.animation = "collected"  #αλλαγή animation - εφέ συλλογής
	collected_sound.play()  #ηχητικό εφέ συλλογής
	collected.emit()  #εκπέμπει σήμα για να ενημερωθεί η ζωή του παίκτη
	call_deferred("_disable_collision")

func _disable_collision() -> void:
	# απενεργοποιεί το collision ώστε ο παίκτης να παίρνει 1 κρύσταλλο τη φορά
	collision_polygon_2d.disabled = true 


func _on_animated_sprite_2d_animation_looped() -> void:
	# διαγραφή κρυστάλλου όταν τελειώνει το animation συλλογής
	if animated_sprite_2d.animation == "collected":
		queue_free()
