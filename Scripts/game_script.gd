extends Node3D

#List containing all cameras and current cam index
@onready var cameras = [$"Main Camera", $"Top Camera"]

#variable to contain main GridMap
@onready var grid_map = $GridMap

#variable to cointain raycast to detect clicks in build mode
@onready var raycast = $"Top Camera/RayCast3D"

var current_cam_index = 0
var build_mode = false
var coordinates_check_mode = false
var hover = [null, null, null, null] #array that holds blocks for hover. 4 couse very tetris block size = 4



#Disables all camera except one with current cam index
func set_camera():
	for i in range (cameras.size()):
			cameras[i].current = (i == current_cam_index)

func _input(event: InputEvent) -> void:
	if build_mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			place_block_on_click()
	if build_mode and event is InputEventKey:
		if event.keycode == KEY_Q and event.is_pressed():
			grid_map.rotate_block_backwards()
	if build_mode and event is InputEventKey:
		if event.keycode == KEY_E and event.is_pressed():
			grid_map.rotate_block_forward()
	if coordinates_check_mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			check_coordinates()
			
func get_collision_point():
	#variable to hold mouse position
	var mouse_pos = get_viewport().get_mouse_position()
	
	#setting raycast start point (mouse position), length and direction -> Vector3
	var from = cameras[current_cam_index].project_ray_origin(mouse_pos)
	var to = from + cameras[current_cam_index].project_ray_normal(mouse_pos) * 100
	
	#gets space, creates raycast(from, to) and cointains result
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result.size() > 0:
		#print("Collision point: ", result)
		return result.position  # Return collision point
	else:
		return null  #No collison

#function places block on raycast position
func place_block_on_click():
	var collision_point = get_collision_point()
	#checking if raycast detected any block if so place block on gridmap
	if collision_point != null:
		var grid_pos = grid_map.local_to_map(collision_point)
		grid_map.place_tetris_block(grid_pos, grid_map.current_shape)
		update_hover_mesh()

#function creates block hover on raycast position
func update_hover_cursor():
	var collision_point = get_collision_point()
	if collision_point != null and build_mode:
		var grid_pos = grid_map.local_to_map(collision_point)
		var grid_pos_f = Vector3(grid_pos.x, grid_pos.y, grid_pos.z)
		for i in range(grid_map.current_shape.size()):
			pass
			var block_pos = grid_pos_f + grid_map.current_shape[i]
			var world_pos = grid_map.map_to_local(block_pos)
			world_pos.y += 0.5
			hover[i].global_transform.origin = world_pos
			hover[i].visible = true  # We make sure that hover is visible
	else:
		for h in hover:
			h.visible = false  #Hides hover if it doesnt collide with grid

#prints in output coordinates of clicked point	
func check_coordinates():
	var collision_point = get_collision_point()
	if collision_point != null:
		var grid_pos = grid_map.local_to_map(collision_point)	
		print(grid_pos)
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_camera()
	for i in range(hover.size()):
		hover[i] = MeshInstance3D.new()
		var mesh_lib = grid_map.mesh_library
		if mesh_lib:
			hover[i].mesh = mesh_lib.get_item_mesh(grid_map.block_type)
			add_child(hover[i])
			hover[i].visible = false
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Camera_F1"):
		current_cam_index = 0
		set_camera()
		coordinates_check_mode = false	
	elif Input.is_action_just_pressed("Camera_F2"):
		current_cam_index = 1
		set_camera()
		coordinates_check_mode = false	
	elif Input.is_action_just_pressed("Camera_F9"):
		current_cam_index = 1
		set_camera()
		coordinates_check_mode = true
		build_mode = false
	if build_mode:
		coordinates_check_mode = false	
	update_hover_cursor()

#Signal to enter build mode
func _on_button_pressed() -> void:
	if not build_mode:
		current_cam_index = 1
		build_mode = true
	else:
		current_cam_index = 0
		build_mode = false
	set_camera()

func update_hover_mesh() -> void:
	var mesh_lib = grid_map.mesh_library
	if not mesh_lib:
		return  # Upewnij się, że mesh_library istnieje
	for i in range(hover.size()):
		if hover[i]:
			hover[i].mesh = mesh_lib.get_item_mesh(grid_map.block_type)
