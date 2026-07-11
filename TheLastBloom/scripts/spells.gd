extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var target: Node2D = null
var is_active := false

func _process(_delta: float) -> void:
	if not is_active or target == null:
		visible = false
		return
	
	visible = true
	var start_pos = global_position
	var end_pos = target.global_position
	
	# κατεύθυνση ξορκιού προς στόχο
	if start_pos.x < end_pos.x :
		scale.x = 1
	else:
		scale.x = -1
	
	var distance = start_pos.distance_to(end_pos)
	
	var original_width = 74.0 
	sprite.scale.x = distance / original_width
