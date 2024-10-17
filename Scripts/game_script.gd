extends Node3D

#List containing all cameras and current cam index
@onready var cameras = [$"Main Camera", $"Top Camera"]
var current_cam_index = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_camera(current_cam_index)

#Disables all camera except one with current cam index
func set_camera(index: int):
	for i in range (cameras.size()):
			cameras[i].current = (i == current_cam_index)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Camera_F1"):
		current_cam_index = 0
		set_camera(current_cam_index)
	elif Input.is_action_just_pressed("Camera_F2"):
		current_cam_index = 1
		set_camera(current_cam_index)
