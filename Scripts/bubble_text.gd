extends PanelContainer

signal X_button_pressed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = false
	
func _on_mouse_entered() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = true

func _on_mouse_exited() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = false


func _on_texture_button_pressed() -> void:
	emit_signal("X_button_pressed")
