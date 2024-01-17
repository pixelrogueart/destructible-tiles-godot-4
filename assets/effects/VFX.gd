extends Node2D
@onready var animations = $AnimatedSprite2D
var library = {
	"SMOKE": ["smoke", "smoke2"],
}

func _ready():
	randomize()

func setup(effect_name, pos):
	self.global_position = pos
	var effect_id = library[effect_name][randi()%library[effect_name].size()]
	animations.play(effect_id)

func _on_animated_sprite_2d_animation_finished():
	self.queue_free()
