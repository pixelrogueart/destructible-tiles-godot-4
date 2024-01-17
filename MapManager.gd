extends Node2D

@onready var tilemap = $TileMap

func _ready():
	SignalManager.connect("SPAWN_BLOCK_PARTICLES",spawn_block_particles)
	randomize()

func _unhandled_input(event):
	if event.is_action_pressed("LEFT_MOUSE"):
		damage_block(get_global_mouse_position())
	if event.is_action_pressed("RIGHT_MOUSE"):
		fall_block(get_global_mouse_position())

#Damages the block in the clicked position.
func damage_block(pos, damage = 1):
	#If the position is a vector 2 and not a vector2i, convert it to vector2i. This assures that both Global coordinates and local map coordinates works!
	if pos is Vector2:
		pos = tilemap.local_to_map(pos)
	#Grabs the atlas coordinates from the tileset so we can start deducting the x value.
	var atlas_coord = tilemap.get_cell_atlas_coords(0,pos,true)
	#Retrieve the terrain type from a custom function.
	var block_type = retrieve_terrain(pos)
	#Variable to store the next atlas coordinates. This is so we can check if the tile been destroyed.
	var new_atlas_coord
	#If the current atlas coordinate is a valid tile, meaning, if it still has "health".
	if atlas_coord != Vector2i(-1,-1):
		#Plays the referenced audio.
		AudioManager.play_audio("STONE_HIT")
		#We then can deduct 1 from the x value.
		tilemap.set_cell(0,pos,0,atlas_coord - Vector2i(damage,0))
		new_atlas_coord = tilemap.get_cell_atlas_coords(0,pos,true)
		#Now we check again, if the new value is negative.
		if new_atlas_coord.x <= -1:
			#We can destroy the block.
			destroy_block(pos,atlas_coord, block_type)
		#Custom function to spawn some physics "particles".
		spawn_block_particles(block_type, 2, tilemap.map_to_local(pos),false)
		#And spawn a small fx.
		EffectsManager.play_vfx_at("SMOKE", tilemap.map_to_local(pos))
	#Retuns the new atlas coord just in case you might need it.
	return new_atlas_coord

#Releases the block, without damaging it.
#Closer logic to the previous function.
func fall_block(pos):
	if pos is Vector2:
		pos = tilemap.local_to_map(pos)
	var atlas_coord = tilemap.get_cell_atlas_coords(0,pos,true)
	var block_type = retrieve_terrain(pos)
	if atlas_coord != Vector2i(-1,-1):
		AudioManager.play_audio("STONE_BREAK")
		destroy_block(pos,atlas_coord, block_type, false)
		EffectsManager.play_vfx_at("SMOKE", get_global_mouse_position())

#Destroys the block.
func destroy_block(pos,atlas_coord,block_type = "DIRT", apply_force = true):
	#We set the cell in the tilemap to negative value, meaning we erase it.
	tilemap.set_cell(0,pos,0,Vector2(-1,-1))
	#We load a physics block and add it.
	var physics_block = load("res://assets/physics-block/PhysicsBlock.tscn").instantiate()
	self.add_child(physics_block)
	#We setup the block to match the current tile. This way we avoid spawning a dirt physics block on a sand tile for example. 
	physics_block.setup(atlas_coord,tilemap.map_to_local(pos),block_type, apply_force)
	#Custom function to spawn some physics "particles".
	spawn_block_particles(block_type, 4, tilemap.map_to_local(pos))

#Retrieve the terrain name at the position.
func retrieve_terrain(pos):
	if pos is Vector2:
		pos = tilemap.local_to_map(pos)
	#Get the cell data at the position.
	var tile_data = tilemap.get_cell_tile_data(0,pos,true)
	#Variable to store the name.
	var terrain_string
	#Checks if there's data at the position.
	if tile_data:
		var terrain_set = tile_data.terrain_set
		var terrain_id = tile_data.terrain
		#Store the string.
		terrain_string = tilemap.tile_set.get("terrain_set_%s/terrain_%s/name"%[terrain_set,terrain_id])
	return terrain_string

#Spawn block physics particles. Might be a better way to do it with Godot particles but I didn't want it.
func spawn_block_particles(block_type = "DIRT", max_particles = 6, pos = Vector2(0,0), start_collision = true):
	#Checks if the block exists in the tile data.
	if block_type in GameData.tileData:
		if "PARTICLE_TYPE" in GameData.tileData[block_type]:
			#Loads the block type, otherwise it will be generic dirt.
			block_type = GameData.tileData[block_type]["PARTICLE_TYPE"]
	#Randomize the amount based on the maximum.
	var particles_amount = randi_range(1,max_particles)
	for i in range(particles_amount):
		#Loads and spawns the block at the position.
		var block_particle = load("res://assets/physics-block/BlockParticle.tscn").instantiate()
		add_child(block_particle)
		block_particle.setup(pos, block_type, start_collision)
