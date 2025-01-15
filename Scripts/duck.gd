extends MeshInstance3D

func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			$PanelContainer.visible = true
			$Timer.start()

func _on_timer_timeout() -> void:
	get_parent().easter_egg = 1
	self.queue_free()
