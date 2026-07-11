class_name jumpLand extends AnimatedSprite2D

@onready var jump_land: AnimatedSprite2D = $"."

enum TYPE {JUMP, LAND} # 2 καταστάσεις του εφέ

func start(type: TYPE) -> void:
	var anim: String = "jump"
	match type:
		TYPE.JUMP:
			position.y -= 14 # για ευθυγράμμιση με τα πόδια κατά το άλμα
		TYPE.LAND:
			position.y -= 14
			anim = "land"
			
	jump_land.animation = anim
	await  jump_land.animation_finished
	queue_free()
