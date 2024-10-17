extends Node3D

#List containing all cameras and current cam index
@onready var cameras = [$"Main Camera", $"Top Camera"]

#variable to contain main GridMap
@onready var grid_map = $GridMap

#variable to cointain raycast to detect clicks in build mode
@onready var raycast = $"Top Camera/RayCast3D"

var current_cam_index = 0
var build_mode = false

#Disables all camera except one with current cam index
func set_camera():
	for i in range (cameras.size()):
			cameras[i].current = (i == current_cam_index)

func _input(event: InputEvent) -> void:
	if build_mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			place_block_on_click()

func place_block_on_click():
	
	#variable to hold mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	#setting raycast start point (mouse position), length and direction -> Vector3
	var from = cameras[current_cam_index].project_ray_origin(mouse_pos)
	var to = from + cameras[current_cam_index].project_ray_normal(mouse_pos) * 1000
	
	#gets space, creates raycast(from, to) and sends cointains result
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	#checking if raycast detected any block if so place block on gridmap
	if result.size()>0:
		var collision_point = result.position
		var grid_pos = grid_map.local_to_map(collision_point)
		grid_map.place_block(grid_pos)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_camera()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Camera_F1"):
		current_cam_index = 0
		set_camera()
	elif Input.is_action_just_pressed("Camera_F2"):
		current_cam_index = 1
		set_camera()


#Signal to enter build mode
func _on_button_pressed() -> void:
	if not build_mode:
		current_cam_index = 1
		build_mode = true
	else:
		current_cam_index = 0
		build_mode = false
	set_camera()
