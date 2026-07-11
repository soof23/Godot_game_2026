extends Area2D

signal player_die

# όταν ο παίκτης ακουμπήσει τα καρφία
# στέλνει σήμα ότι χτυπήθηκε
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		emit_signal("player_die", body)
