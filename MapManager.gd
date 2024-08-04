class_name MapManager
extends Node2D

@onready var tilemap = $TileMap
@onready var check_timer: Timer = $CheckTimer
@onready var fall_timer: Timer = $FallTimer
var check_queue = 0
var blocks_to_fall = []

func _ready():
	SignalManager.connect("SPAWN_BLOCK_PARTICLES", spawn_block_particles)
	GameManager.map_manager = self
	randomize()

func _unhandled_input(event):
	if event.is_action_pressed("LEFT_MOUSE"):
		damage_block(get_global_mouse_position())
	if event.is_action_pressed("MIDDLE_MOUSE"):
		var center_pos = tilemap.local_to_map(get_global_mouse_position())
		fall_disconnected_blobs(center_pos, 32)
	if event.is_action_pressed("RIGHT_MOUSE"):
		fall_block(get_global_mouse_position())

func damage_block(pos, damage = 1):
	if pos is Vector2:
		pos = tilemap.local_to_map(pos)
	var atlas_coord = tilemap.get_cell_atlas_coords(0, pos, true)
	var block_type = retrieve_terrain(pos)
	if block_type == "BLACKROCK":
		printerr("Cannot damage blackrock.")
		return
	var new_atlas_coord
	if atlas_coord != Vector2i(-1, -1):
		AudioManager.play_audio("STONE_HIT")
		tilemap.set_cell(0, pos, 0, atlas_coord - Vector2i(damage, 0))
		new_atlas_coord = tilemap.get_cell_atlas_coords(0, pos, true)
		if new_atlas_coord.x <= -1:
			destroy_block(pos, atlas_coord, block_type)
		spawn_block_particles(block_type, 2, tilemap.map_to_local(pos), false)
		EffectsManager.play_vfx_at("SMOKE", tilemap.map_to_local(pos))
	return new_atlas_coord

func fall_block(pos):
	if pos is Vector2:
		pos = tilemap.local_to_map(pos)
	var atlas_coord = tilemap.get_cell_atlas_coords(0, pos, true)
	var block_type = retrieve_terrain(pos)
	if atlas_coord != Vector2i(-1, -1):
		AudioManager.play_audio("STONE_BREAK")
		destroy_block(pos, atlas_coord, block_type, false)
		EffectsManager.play_vfx_at("SMOKE", tilemap.map_to_local(pos))

func destroy_block(pos, atlas_coord, block_type = "DIRT", apply_force = true):
	tilemap.set_cell(0, pos, 0, Vector2(-1, -1))
	var physics_block = load("res://assets/physics-block/PhysicsBlock.tscn").instantiate()
	self.add_child(physics_block)
	physics_block.setup(atlas_coord, tilemap.map_to_local(pos), block_type, apply_force)
	spawn_block_particles(block_type, 4, tilemap.map_to_local(pos))

func retrieve_terrain(pos):
	if pos is Vector2:
		pos = tilemap.local_to_map(pos)
	var tile_data = tilemap.get_cell_tile_data(0, pos, true)
	var terrain_string
	if tile_data:
		var terrain_set = tile_data.terrain_set
		var terrain_id = tile_data.terrain
		terrain_string = tilemap.tile_set.get("terrain_set_%s/terrain_%s/name" % [terrain_set, terrain_id])
	return terrain_string

func spawn_block_particles(block_type = "DIRT", max_particles = 6, pos = Vector2(0, 0), start_collision = true):
	if block_type in GameData.tileData:
		if "PARTICLE_TYPE" in GameData.tileData[block_type]:
			block_type = GameData.tileData[block_type]["PARTICLE_TYPE"]
	var particles_amount = randi_range(1, max_particles)
	for i in range(particles_amount):
		var block_particle = load("res://assets/physics-block/BlockParticle.tscn").instantiate()
		call_deferred("add_child", block_particle)
		block_particle.pos = pos
		block_particle.type = block_type
		block_particle.start_collision = start_collision

func find_blob(start_pos: Vector2i, block_type: String, visited: Dictionary) -> Dictionary:
	var stack = [start_pos]
	var blob = {
		"positions": [],
		"connected_to_blackrock": false
	}

	while stack.size() > 0:
		var current_pos = stack.pop_back()
		if current_pos in visited:
			continue

		visited[current_pos] = true
		blob["positions"].append(current_pos)

		for offset in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var neighbor_pos = current_pos + offset
			if !is_within_tilemap_bounds(neighbor_pos):
				continue
			if neighbor_pos in visited:
				continue

			var neighbor_block_type = retrieve_terrain(neighbor_pos)
			if neighbor_block_type == block_type:
				stack.append(neighbor_pos)
			elif neighbor_block_type == "BLACKROCK":
				blob["connected_to_blackrock"] = true

	return blob

func is_within_tilemap_bounds(pos: Vector2i) -> bool:
	var used_rect = tilemap.get_used_rect()
	return pos.x >= used_rect.position.x and pos.x < used_rect.end.x and pos.y >= used_rect.position.y and pos.y < used_rect.end.y

func fall_disconnected_blobs(center_pos: Vector2i, range: int):
	var visited = {}
	var blobs_to_fall = []

	for x in range(center_pos.x - range, center_pos.x + range + 1):
		for y in range(center_pos.y - range, center_pos.y + range + 1):
			var pos = Vector2i(x, y)
			if !is_within_tilemap_bounds(pos):
				continue
			if pos in visited:
				continue

			var block_type = retrieve_terrain(pos)
			if block_type and block_type != "BLACKROCK":
				var blob = find_blob(pos, block_type, visited)
				if not blob["connected_to_blackrock"]:
					blobs_to_fall.append(blob["positions"])

	for blob in blobs_to_fall:
		for pos in blob:
			if not pos in blocks_to_fall:
				blocks_to_fall.append(pos)

func _on_check_timer_timeout():
	fall_disconnected_blobs(GameManager.main_camera.global_position, 32)
	if blocks_to_fall.size() > 0:
		if fall_timer.is_stopped():
			fall_timer.start(0.05)


func _on_fall_timer_timeout():
	var pos = blocks_to_fall.pop_front()
	fall_block(pos)
