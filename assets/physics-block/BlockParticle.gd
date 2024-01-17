extends RigidBody2D

@onready var sprite = $Sprite2D
@onready var timer = $Timer
var gib_library = {
	"DIRT": "res://resources/dirts.png",
	"STONE": "res://resources/rocks.png",
}

func _ready():
	randomize()
	setup()
	timer.start(randf_range(2,4))

func setup(pos = Vector2(0,0), type = "DIRT", start_collision = true):
	if !start_collision:
		$CollisionShape2D.disabled = true
		z_index = 2
	sprite.texture = AtlasTexture.new()
	sprite.texture.atlas = load(gib_library[type])
	var frame_number = sprite.texture.atlas.get_height()/8
	var frame = randi_range(0,frame_number)
	sprite.texture.region.size = Vector2(8,8)
	sprite.texture.region.position = Vector2(0,frame * 8)
	self.global_position = Vector2(pos.x,pos.y) #+ Vector2(randf_range(-4,4),randf_range(-4,4))
	var random_direction = Vector2(randf_range(-1,1), randf_range(-1,1))
	var random_strength = randf_range(10.0, 50.0) # Adjust these values as needed
	var force = random_direction * random_strength
	apply_force(force * 100, random_direction * 10)

func _on_timer_timeout():
	self.queue_free()
