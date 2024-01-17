extends RigidBody2D
@export var tile_size = 8

@onready var sprite = $Sprite2D
@onready var timer = $Timer

var block_type = ""
var hovering = false
var health = 10.0


func _ready():
	randomize()
	#Starts a timer to destroy the block after a while.
	timer.start(randf_range(2,4))

#Function to setup the tile based on the type.
func setup(coords:Vector2i,pos:Vector2,_block_type = "DIRT",apply_force = true):
	block_type = _block_type
	#Loads the texture based on the atlas coordinates by multiplying the tile size, in my case it's 8. Change in the tile_size variable if different.
	sprite.texture.region.size = Vector2(tile_size,tile_size)
	sprite.texture.region.position = Vector2(coords.x,coords.y) * tile_size
	self.global_position = pos
	#Makes the tile apply force to a random direction, this leaves a better look.
	if apply_force:
		var random_direction = Vector2(randf_range(-1,1), randf_range(-1,1))
		var random_strength = randf_range(10.0, 50.0) # Adjust these values as needed
		var force = random_direction * random_strength
		self.look_at(random_direction * 10)
		apply_force(force * 100, random_direction * 10)

#Destroys the block.
func destroy():
	SignalManager.emit_signal("SPAWN_BLOCK_PARTICLES",block_type, 4, self.global_position)
	AudioManager.play_audio("STONE_BREAK")
	self.queue_free()

#--------------------
#Start debug functions.
func _unhandled_input(event):
	if event.is_action_pressed("LEFT_MOUSE"):
		if hovering:
			destroy()

func _on_mouse_entered():
	hovering = true

func _on_mouse_exited():
	hovering = false

#End debug functions.
#--------------------

func _on_timer_timeout():
	destroy()

#If collides with anything, it loses health until destroyed. You could apply damage to a player as well.
func _on_body_entered(body):
	AudioManager.play_audio("LAND")
	var speed = linear_velocity.length()
	health -= speed/2
	SignalManager.emit_signal("SPAWN_BLOCK_PARTICLES",block_type, 4, self.global_position)
	if health <= 0:
		destroy()

func _on_area_2d_body_entered(body):
	var speed = linear_velocity.length()
