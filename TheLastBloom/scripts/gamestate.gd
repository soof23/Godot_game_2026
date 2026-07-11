extends Node

var drops: int = 0 #πλήθος σταγόνων για το τελικό λουλούδι
var level: int = 0 #πίστα
var player_health: int = 5 #ζωή του παίκτη 
var total_damages: int = 0 #χτυπήματα που δέχτηκε ο παίκτης
var total_crystals: int = 0 #κρύσταλλοι που μαζεύτηκαν
var time_taken: int = 0 #συνολικός χρόνος παιχνιδιού
var limit_level3: bool = true #αν είναι στό σημείο του αέρα
var is_shielding = false #αν ο παίκτης χρησιμοποιεί την ασπίδα αέρα
const min_health: int = 0
const max_health: int = 5

# επαναφορά στην πρώτη πίστα
func reset():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	drops = 0
	level = 1
	player_health = 5
	total_damages = 0
	total_crystals = 0
	time_taken = 0
	limit_level3 = true
	is_shielding = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

# επιστροφή στο κεντρικό μενού
func restart():
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
	drops = 0
	level = 0
	player_health = 5
	total_damages = 0
	total_crystals = 0
	time_taken = 0
	limit_level3 = true
	is_shielding = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func start_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
