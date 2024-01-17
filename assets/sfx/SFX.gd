extends AudioStreamPlayer

func _on_sfx_finished():
	self.queue_free()
