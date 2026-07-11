extends Node2D

@onready var stormeffect: ColorRect = $stormeffect
var timer = 0.0

func _ready() -> void:
	visible = true

func _process(delta: float) -> void:
	# τρέχει μόνο αν ο παίκτης δεν χρησιμοποιεί ασπίδα και βρίσκεται στη φάση του αέρα
	if !GameState.is_shielding and GameState.limit_level3 == true: 
		apply_storm_effect(delta) 
	else:
		stormeffect.color.a = 0

# ένταση
func apply_storm_effect(delta):
	timer += delta
	var base_flicker = (sin(timer * 15.0) * 0.5 + 0.5) * 0.2
	var strike = 0.0
	# κάθε frame έχει 2% πιθανότητα να δημιουργήσει μια πιο ισχυρή λάμψη 
	if randf() > 0.98: 
		strike = randf_range(0.5, 0.8)
	stormeffect.color.a = clamp(base_flicker + strike, 0.0, 1.0)
