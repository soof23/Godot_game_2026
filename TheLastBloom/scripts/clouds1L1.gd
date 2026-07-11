#κίνηση των σύννεφων στο Parallax Background 
extends ParallaxLayer

const CLOUD_SPEED = -4

func _process(delta: float) -> void:
	if GameState.level == 3 and GameState.limit_level3 == true:
		# τα σύννεφα κινούνται με διπλάσια ταχύτητα λόγω του αέρα
		self.motion_offset.x += CLOUD_SPEED * delta * 2
	else:
		# κίνηση συννέφων
		self.motion_offset.x += CLOUD_SPEED * delta
