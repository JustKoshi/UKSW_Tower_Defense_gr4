class_name Tavern
extends MeshInstance3D
var game_script

var generator_on = true
var resource_type = "beer"

var generation_depleted = true

var shape = [Vector3(0,0,0)]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	generator_on = true
