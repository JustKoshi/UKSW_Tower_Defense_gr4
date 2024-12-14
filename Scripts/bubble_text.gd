extends PanelContainer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = false
	
func _on_mouse_entered() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = true

func _on_mouse_exited() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = false
