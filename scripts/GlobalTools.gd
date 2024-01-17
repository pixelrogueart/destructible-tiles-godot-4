extends Node

func load_json(_path:String):
	var file = FileAccess.open(_path, FileAccess.READ)
	var content = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(content)
	if error == OK:
		var dataReceived = json.data
		return dataReceived
	else:
		print("JSON Parse Error")
		return null

func save_json(_path:String):
	pass

func string_to_vector2(s: String) -> Vector2:
	var parts = s.replace("(", "").replace(")", "").split(",")
	return Vector2(int(parts[0]), int(parts[1]))

func string_to_vector2i(s: String) -> Vector2i:
	var parts = s.replace("(", "").replace(")", "").split(",")
	return Vector2i(int(parts[0]), int(parts[1]))

func vector2_to_string(vec: Vector2) -> String:
	return "(%s, %s)" % [vec.x, vec.y]

func load_data(fileName) -> Dictionary:
	var data = GlobalTools.load_json("res://data/"+fileName+".json")
	if data:
		return data
	return {}
	
