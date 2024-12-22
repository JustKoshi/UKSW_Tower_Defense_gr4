extends PanelContainer

var object

signal X_button_pressed
signal upgrade_pressed(object)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not self.name == "Tetris building panel" and not self.name == "Workers buying panel":
		get_child(1).get_child(1).get_child(0).get_child(0).visible = false
		object = null
	
func _on_mouse_entered() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = true

func _on_mouse_exited() -> void:
	get_child(1).get_child(1).get_child(0).get_child(0).visible = false


func _on_texture_button_pressed() -> void:
	emit_signal("X_button_pressed")


func _on_upgrade_button_pressed() -> void:
	emit_signal("upgrade_pressed",object)
