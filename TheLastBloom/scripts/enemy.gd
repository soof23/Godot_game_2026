extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft
@onready var death_sound: AudioStreamPlayer2D = $DeathSound

signal player_died
var  SPEED = 10.0
var direction = -1.0
var alive = true

func _process(delta: float) -> void:
	if !alive:
		return
	
	# αλλαγή κατεύθυνσης στην κίνηση
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite_2d.flip_h = true
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite_2d.flip_h = false
		
	position.x += direction * SPEED * delta
	
	#αλλαγή animation ανάλογα με την πίστα
	if GameState.level == 1:
		animated_sprite_2d.animation = "idleLevel1"
	elif GameState.level >= 2:
		animated_sprite_2d.animation = "idleLevel2"

# όταν ο εχθρός συγκρουστεί με κάποιο σώμα
# αν το σώμα είναι ο παίκτης και ο παίκτης είναι ζωντανός, στέλνει σήμα ότι τον χτύπησε
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player" and body.alive:
		emit_signal("player_died", body)

func die() -> void:
	if !alive : return
	alive = false
	death_sound.play() #ηχητικό εφέ
	$CollisionShape2D.disabled = true #απενεργοποιεί το collision για να μην ξαναχτυπήσει τον παίκτη 
	
	# animation εξαφάνισης
	if GameState.level == 1:
		animated_sprite_2d.animation = "dieLevel1"
	elif GameState.level >= 2:
		animated_sprite_2d.animation = "dieLevel2"
	await get_tree().create_timer(1.0).timeout

# όταν τελειώσει το animation θανάτου, αφαιρεί τον εχθρό από τη σκηνή
func _on_animated_sprite_2d_animation_looped() -> void:
	if animated_sprite_2d.animation == "dieLevel1":
		queue_free()
	if animated_sprite_2d.animation == "dieLevel2":
		queue_free()
