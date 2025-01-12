extends PanelContainer

var object

signal X_button_pressed
signal upgrade_pressed(object)
signal upgrade_hovered(object)
signal upgrade_unhovered(object)
signal destroy_pressed(object)
signal repair_pressed(object)

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


func _on_upgrade_button_mouse_entered() -> void:
	emit_signal("upgrade_hovered",object)


func _on_upgrade_button_mouse_exited() -> void:
	emit_signal("upgrade_unhovered",object)


func _on_destroy_button_pressed() -> void:
	emit_signal("destroy_pressed",object)


func _on_repair_button_pressed() -> void:
	emit_signal("repair_pressed",object)
