extends TileMap
#
#@onready var check_timer = $CheckTimer
#
#var check_index = 0
#var check_limit = 1
#var tile_size = Vector2(8, 8)  # Adjust this if your tiles are a different size
#
#func detect_tiles(ul: Vector2, lr: Vector2) -> bool:
	#var tilesize = 8
	#var tpos = ul
	#while tpos.x < lr.x:
		#while tpos.y < lr.y:
			#if get_used_cells(0).has(Vector2i(tpos)):
				#return true
			#tpos.y += tilesize
		#tpos.x += tilesize
		#tpos.y = ul.y
	#return false
#
#func check_all_positions():
	#var cells = get_used_cells(0)
	#var checked_count = 0
	#while checked_count < check_limit and check_index < cells.size():
		#var cell = cells[check_index]
		#var pos = map_to_local(cell)
		#var tl = pos - tile_size
		#var br = pos + tile_size
		#if not detect_tiles(tl, br):
			#if not detect_tiles(tl + Vector2(1, 0), br + Vector2(-1, 8)):
				#get_parent().fall_block(pos)
		#check_index += 1
		#checked_count += 1
	#if check_index >= cells.size():
		#check_index = 0
#
#func _on_check_timer_timeout():
	#check_all_positions()
#
#func _ready():
	#check_timer.wait_time = 0.1
	#check_timer.start()
