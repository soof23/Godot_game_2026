extends Node

const JUMP_LAND = preload("uid://csanwdkshd7n5")

#create effects
func _create_dust_effect(pos: Vector2)-> jumpLand:
	var dust : jumpLand = JUMP_LAND.instantiate() 
	add_child(dust)
	dust.global_position = pos
	return dust

#jump
func jump_dust(pos: Vector2)->void:
	var dust : jumpLand = _create_dust_effect(pos)
	dust.start(jumpLand.TYPE.JUMP)
	
#land
func land_dust(pos: Vector2)->void:
	var dust : jumpLand = _create_dust_effect(pos)
	dust.start(jumpLand.TYPE.LAND)
