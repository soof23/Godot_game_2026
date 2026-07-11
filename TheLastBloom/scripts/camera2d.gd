extends Camera2D

@export var shake_amplitude: float = 10.0
@export var shake_duration: float = 0.2
var tween: Tween

func shake() -> void:
	if tween and tween.is_running():
		tween.kill()
		
	var master_bus_idx = AudioServer.get_bus_index("Master")
	var distortion = AudioServer.get_bus_effect(master_bus_idx, 0) as AudioEffectDistortion
	
	tween = create_tween()
	tween.set_parallel(false)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	var start_offset: Vector2 = Vector2.ZERO # αρχική θέση της κάμερας
	# υπολογισμός τυχαίας θέσης (X, Y) στα όρια του shake_amplitude
	var end_offset: Vector2 = Vector2(
		randf_range(-shake_amplitude, shake_amplitude),
		randf_range(-shake_amplitude, shake_amplitude)
	)
	
	# μετακίνηση της κάμερας στην τυχαία θέση στη μισή διάρκεια του shake_duration 
	tween.tween_property(self, "offset", end_offset, shake_duration / 2)
	# ταυτόχρονα, distortion στο κεντρικό κανάλι του ήχου
	tween.parallel().tween_property(distortion, "drive", 0.3, shake_duration / 2)
	
	# επαναφορά της κάμερας 
	tween.tween_property(self, "offset", start_offset, shake_duration / 2)
	# μηδενισμός distortion του ήχου
	tween.parallel().tween_property(distortion, "drive", 0.0, shake_duration / 2)
