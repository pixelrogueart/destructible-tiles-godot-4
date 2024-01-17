extends Node

func _ready():
	randomize()

var audio_library = {
	"STONE_HIT":["res://resources/sfx/stone_hit.wav", "res://resources/sfx/stone_hit_2.wav"],
	"STONE_BREAK":["res://resources/sfx/stone_break.wav"],
	"LAND":["res://resources/sfx/land.wav", "res://resources/sfx/land_2.wav"],
}

func play_audio(audio_name):
	var sfx = load("res://assets/sfx/SFX.tscn").instantiate()
	get_node("/root").add_child(sfx)
	var audio = load(audio_library[audio_name][randi()%audio_library[audio_name].size()])
	sfx.stream = audio
	sfx.play()
