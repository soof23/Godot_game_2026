extends StaticBody2D

var showing = false

# όταν η πλατφόρμα ανιχνεύσει τον παίκτη, εμφανίζεται
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive and !showing:
		showing = true
		$AnimationPlayer.play("fadeIn")
