extends PanelContainer

var object

signal X_button_pressed_r
signal destroy_pressed_r(object)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not self.name == "Tetris building panel" and not self.name == "Workers buying panel" and not self.name == "Tower panel":
		#get_child(1).get_child(1).get_child(0).get_child(0).visible = false
		object = null

func _on_texture_button_pressed() -> void:
	emit_signal("X_button_pressed_r")

func _on_destroy_button_pressed() -> void:
	emit_signal("destroy_pressed_r",object)
