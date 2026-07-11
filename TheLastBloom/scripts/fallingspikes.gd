extends Node2D

@export var speed: float = 160.0
var current_speed: float = 0.0

signal player_die

func _physics_process(delta: float) -> void:
	position.y += current_speed * delta  #πέφτει

# όταν το HitBox των καρφιών βρει τον παίκτη
func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		emit_signal("player_die", body) # εκπέμπει ότι χτύπησε τον παίκτη
		queue_free() #εξαφανίζονται

# όταν ο παίκτης μπει στην αόρατη περιοχή κάτω από τα καρφιά
func _on_player_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		fall() #ενεργοποιέι πτώση
		$AnimationPlayer.play("shake") #animation που κουνιέται λίγο αριστερά δεξιά κατα την πτώση
		await get_tree().create_timer(9.0).timeout 
		queue_free()

func fall() -> void:
	current_speed = speed
