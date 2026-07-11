extends GPUParticles2D

var last_mouse_pos = Vector2.ZERO

func _process(_delta: float) -> void:
	var current_mouse_pos = get_global_mouse_position() #τρέχουσα θέση του ποντικιού
	global_position = current_mouse_pos #particles στη θέση του ποντικιού
	
	# απόσταση από το προηγούμενο frame
	var distance = current_mouse_pos.distance_to(last_mouse_pos)
	
	if distance > 0:
		# αν το ποντίκι κινείται αυξάνεται η αναλογία των σωματιδίων ανάλογα με την απόσταση
		amount_ratio = clamp(distance / 20.0, 0.2, 1.0)
	else:
		amount_ratio = lerp(amount_ratio, 0.1, 0.1)
	
	last_mouse_pos = current_mouse_pos  #ανανεώνει την τελευταία θέση για το επόμενο frame
