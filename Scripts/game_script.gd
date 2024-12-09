extends Node3D

#List containing all cameras and current cam index
@onready var cameras = [$"Main Camera", $"Top Camera", $"Front camera", $"Resource Camera" ]

#variable to contain main GridMap
@onready var grid_map = $GridMap

#variables to contain build time logoic and ui label informing about build time
@onready var build_timer = $"Build Timer"
@onready var build_time_label = $"CanvasLayer/UI/Build time Label"
@onready var switch_label_timer = $"Switch Label Timer"

#variable to contain raycast to detect clicks in build mode
@onready var raycast = $"Top Camera/RayCast3D"

#variable to contain Enemy Path Spawner
@onready var enemy_spawner = $"Enemy Spawner"

@onready var UI = $CanvasLayer/UI
@onready var GameOver = $CanvasLayer/UI/GameOverScreen

var NormalTowerScene = preload("res://Scenes/normal_tower_lvl_1.tscn")
var FreezeTowerScene = preload("res://Scenes/Freeze_tower_lvl_1.tscn")
var Lumbermill = preload("res://Scenes/lumbermill.tscn")
var Mine = preload("res://Scenes/mine.tscn")

var tower_build = false
var tetris_build_mode = false
var tower_mode = false
var resource_build = false
var resource_mode = false

var wood_build = false
var wheat_build = false
var stone_build = false
var beer_build = false

var walls_build = false
var normal_tower_build = false
var freeze_tower_build = false
var aoe_tower_build = false


var hovering_tower = 0

var tower_to_hover = 0#Which tower is picked with button 0-none 1-normal 2-freeze 3-aoe

var hovering_resource = 0
var resource_to_hover = 0#0 for none, 1 for lumbermill, 2 for mine
var resource_shape

var current_cam_index = 0
var coordinates_check_mode = false
var hover = [null, null, null, null] #array that holds blocks for hover. 4 couse very tetris block size = 4
var short_path = [] #array that holds shortest path converted to local

var tower_hover_holder:MeshInstance3D = null#Object that holds tower instance that is now currently selected and might be placed
var resource_hover_holder:MeshInstance3D = null


#resource counter:
var game_resources = {
	"wood": 0,
	"stone": 0,
	"wheat": 0,
	"beer": 0
}
var max_health = 15
var current_health
var game = true

var wave_number = 1
var is_build_phase = true

var texture_png = load("res://Resources/Towers/hexagons_medieval.png")
var red_mat = StandardMaterial3D.new()
var normal_mat = StandardMaterial3D.new()
var red_mat_range = StandardMaterial3D.new()
var normal_mat_range = StandardMaterial3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_health = max_health
	game = true
	GameOver.visible = false
	$CanvasLayer/UI/GameOverScreen/VBoxContainer/MainMenu_button.disabled = true
	$CanvasLayer/UI/GameOverScreen/VBoxContainer/PlayAgain_button.disabled = true
	red_mat.albedo_color = Color(1,0,0,0.55)
	normal_mat.albedo_color = Color(1,1,1,0.55)
	normal_mat_range.albedo_color = Color(0,0,0,0.55)
	red_mat_range.albedo_color = Color(1,0,0,0.55)
	red_mat.albedo_texture = texture_png
	normal_mat.albedo_texture = texture_png
	red_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	normal_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	normal_mat_range.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	red_mat_range.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	set_camera()
	update_label_build_time()
	var mesh_lib = grid_map.mesh_library
	for i in range(hover.size()):
		hover[i] = MeshInstance3D.new()
		if mesh_lib:
			hover[i].mesh = mesh_lib.get_item_mesh(grid_map.block_type)
			add_child(hover[i])
			hover[i].visible = false
	convert_path_to_local()
	enemy_spawner.set_path(short_path)
	UI.update_enemy_count_labels(enemy_spawner.basic_enemies_per_wave, enemy_spawner.fast_enemies_per_wave, 0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	update_resource_timers()
	if Input.is_action_just_pressed("Camera_F1"):
		if current_cam_index >0 :
			current_cam_index -= 1
		current_cam_index = current_cam_index%3
		set_camera()
		
	elif Input.is_action_just_pressed("Camera_F2"):
		current_cam_index += 1
		current_cam_index = current_cam_index%3
		set_camera()
		
	elif Input.is_action_just_pressed("Camera_F9"):
		current_cam_index = 1
		set_camera()
		if !coordinates_check_mode:
			coordinates_check_mode = true
		else:
			coordinates_check_mode = false
	
	if walls_build:
		set_build_cam()
		update_hover_tetris()
	if normal_tower_build:
		tower_to_hover = 1
		hover_tower(tower_to_hover)
		set_build_cam()
	if freeze_tower_build:
		tower_to_hover = 2
		hover_tower(tower_to_hover)
		set_build_cam()
	if not normal_tower_build and not freeze_tower_build:
		tower_to_hover = 0
	if wood_build:
		set_resource_cam()
		coordinates_check_mode = false
		resource_to_hover = 1
		hover_resource(resource_to_hover)
	if stone_build:
		set_resource_cam()
		coordinates_check_mode = false
		resource_to_hover = 2
		hover_resource(resource_to_hover)
	if not wood_build and not stone_build:
		resource_to_hover = 0
	if is_build_phase:
		update_label_build_time()
	
	if not game:
		get_node("Main Camera").angle += 0.1 * delta
	#print("wood build: " + str(wood_build))
	#print("wheat build: " + str(wheat_build))
	#print("stone build: "+ str(stone_build))
	#print("beer build: " + str(beer_build))
	#print("walls build: " + str(walls_build))
	#print("normal tower: " + str(normal_tower_build))
	#print("freeze tower: " + str(freeze_tower_build))
	#print("aoe tower: " + str(aoe_tower_build))

func _input(event: InputEvent) -> void:
	if walls_build and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			place_block_on_click()
	if walls_build and event is InputEventKey:
		if event.keycode == KEY_Q and event.is_pressed():
			grid_map.rotate_block_backwards()
		elif event.keycode == KEY_E and event.is_pressed():
			grid_map.rotate_block_forward()
	if coordinates_check_mode and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			check_coordinates()
	if (normal_tower_build or freeze_tower_build) and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			place_tower_on_click(hovering_tower)
	if (wood_build or stone_build) and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			place_resource_on_click(hovering_resource)
			

#Disables all camera except one with current cam index
func set_camera():
	for i in range (cameras.size()):
			cameras[i].current = (i == current_cam_index)

func set_build_cam():
	current_cam_index = 1
	set_camera()

func set_resource_cam():
	current_cam_index = 3
	set_camera()

func get_collision_point(): #returns raycast collision point with map
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
		convert_path_to_local()
		enemy_spawner.set_path(short_path)


#function places tower on raycast position
func place_tower_on_click(tower_type:int):
	if tower_hover_holder != null:
		tower_hover_holder.free()#deleting hover tower before getting collision point
	var collision_point = get_collision_point()
	#checking if raycast detected any block if so place block on gridmap
	if collision_point != null and grid_map.can_place_tower(collision_point):
	#if tower can be placed instantiate tower and change its cordinates and turn off range and turning of hover transparency
		var tower
		if(tower_type==1):
			tower = NormalTowerScene.instantiate()
		elif(tower_type==2):
			tower = FreezeTowerScene.instantiate()
			tower.get_node("MobDetector").get_child(0).disabled=false
		tower.can_shoot = true
		var grid_pos = grid_map.local_to_map(collision_point)
		var place_pos = grid_map.map_to_local(grid_pos)
		place_pos.y+=1.5
		tower.position=place_pos
		var mat = tower.get_active_material(0)
		var mat_dup = mat.duplicate()
		mat_dup.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED
		tower.set_surface_override_material(0,mat_dup)
		if tower_type == 1:
			tower.set_surface_override_material(1,mat_dup)
		tower.get_node("MobDetector").visible=false
		grid_map.place_tower_in_tilemap(collision_point)
		self.get_node("Tower Holder").add_child(tower)
		print("Added tower in position: ",grid_pos)
		tower_hover_holder = null
		hovering_tower = 0

#function that hover towers over the map showing where it can be placed and its range
func hover_tower(_tower_type:int):
	var collision_point = get_collision_point()
	if tower_hover_holder==null or tower_to_hover!=hovering_tower:
		#if there was no hover instantiate 1 hover tower and making its opacity = 0.5
		if(tower_to_hover==1):
			tower_hover_holder = NormalTowerScene.instantiate()
			hovering_tower=1
		elif(tower_to_hover==2):
			tower_hover_holder = FreezeTowerScene.instantiate()
			hovering_tower=2
		tower_hover_holder.can_shoot=false
		get_node("Tower Holder").add_child(tower_hover_holder)
		tower_hover_holder.set_surface_override_material(0,normal_mat)
		if tower_to_hover == 1:
			tower_hover_holder.set_surface_override_material(1,normal_mat)
		if tower_to_hover == 2:
			tower_hover_holder.get_node("Mage").visible = false
	if collision_point != null:
		tower_hover_holder.visible=true
		var grid_pos = grid_map.local_to_map(collision_point)
		var place_pos = grid_map.map_to_local(grid_pos)
		place_pos.y=4.5
		tower_hover_holder.position=place_pos#changing tower position after cursor
		if grid_map.can_place_tower(collision_point):
			#if tower can be placed change its color to normal
			tower_hover_holder.get_node("MobDetector").get_child(1).set_surface_override_material(0,normal_mat_range)
			tower_hover_holder.set_surface_override_material(0,normal_mat)
			if tower_to_hover == 1:
				tower_hover_holder.set_surface_override_material(1,normal_mat)
		else:
			#if it cant be placed change its color to red
			tower_hover_holder.get_node("MobDetector").get_child(1).set_surface_override_material(0,red_mat_range)
			tower_hover_holder.set_surface_override_material(0,red_mat)
			if tower_to_hover == 1:
				tower_hover_holder.set_surface_override_material(1,red_mat)
	else:
		#hide hover if cursor is out of gridmap
		tower_hover_holder.visible=false
	
#function creates block hover on raycast position
func update_hover_tetris():
	var collision_point = get_collision_point()
	if collision_point != null and walls_build:
		var grid_pos = grid_map.local_to_map(collision_point)
		var grid_pos_f = Vector3(grid_pos.x, grid_pos.y, grid_pos.z)
		if grid_map.can_place_tetris_block(grid_pos,grid_map.current_shape):
			#print("mozna")
			update_hover_mesh(true)
			for i in range(grid_map.current_shape.size()):
				var block_pos = grid_pos_f + grid_map.current_shape[i]
				var world_pos = grid_map.map_to_local(block_pos)
				world_pos.y = 3.5
				hover[i].global_transform.origin = world_pos
				hover[i].visible = true  # We make sure that hover is visible
		else:
			#print("NIE")
			update_hover_mesh(false)
			for i in range(grid_map.current_shape.size()):
				var block_pos = grid_pos_f + grid_map.current_shape[i]
				var world_pos = grid_map.map_to_local(block_pos)
				world_pos.y = 3.5
				hover[i].global_transform.origin = world_pos
				hover[i].visible = true 
	else:
		for h in hover:
			h.visible = false  #Hides hover if it doesnt collide with grid

#prints in output coordinates of clicked point	
func check_coordinates():
	var collision_point = get_collision_point()
	if collision_point != null:
		var grid_pos = grid_map.local_to_map(collision_point)	
		print(grid_pos)
		

func color_transparent_mesh_instance(object, color):#1 - transparent, 2 - red/transparent, 3 - normal
	for i in range(object.get_surface_override_material_count()):
			var mat = object.get_surface_override_material(i)
			var mat_dupe = mat.duplicate()
			mat_dupe.flags_transparent = true
			match color:
				1:
					mat_dupe.albedo_color = Color(1,1,1,0.5)
				2:
					mat_dupe.albedo_color = Color(1,0,0,0.5)
				3:
					mat_dupe.albedo_color = Color(1,1,1,1)
					mat_dupe.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED
			object.set_surface_override_material(i,mat_dupe)

func update_resource_timers():
	for i in range(get_node("Resource Holder").get_child_count()):
		var child = get_node("Resource Holder").get_child(i)
		if child.generator_on == true:
			child.get_node("Timer").start()
			child.generator_on = false
			if child.generation_depleted:
				game_resources[child.resource_type] += 0.5#polowa wartosci
			else:
				game_resources[child.resource_type] += 1


func place_resource_on_click(resource_type:int):
	resource_hover_holder.free()
	var collision_point = get_collision_point()
	var building
	#checking if raycast detected any block if so place block on gridmap
	if collision_point != null:
		var grid_pos = grid_map.local_to_map(collision_point)
		if grid_map.can_place_resource(grid_pos, resource_shape):
			if resource_type == 1:
				building = Lumbermill.instantiate()
			elif resource_type == 2:
				building = Mine.instantiate() 
			else:
				return
			var place_pos = grid_map.map_to_local(grid_pos)
			place_pos.y=2.5
			place_pos.x+=1
			place_pos.z+=1
			#print(place_pos)
			building.position=place_pos
			if grid_map.place_resource_in_tilemap(collision_point, hovering_resource):
				building.generation_depleted = true
			get_node("Resource Holder").add_child(building)
			color_transparent_mesh_instance(building,3)
			#print("Added lumbermill in position: ",grid_pos)
			resource_hover_holder=null
			hovering_resource = 0

	
func hover_resource(resource_type:int):
	var collision_point = get_collision_point()
	if resource_hover_holder == null or hovering_resource != resource_type:
		if resource_type==1:
			resource_hover_holder = Lumbermill.instantiate()
			hovering_resource = 1
			resource_shape = resource_hover_holder.shape
			resource_hover_holder.generator_on = false
		elif resource_type == 2:
			resource_hover_holder = Mine.instantiate()
			hovering_resource = 2
			resource_shape = resource_hover_holder.shape
			resource_hover_holder.generator_on = false
		else:
			return
		resource_hover_holder.game_script = self
		get_node("Resource Holder").add_child(resource_hover_holder)
	if collision_point != null:
		var grid_pos = grid_map.local_to_map(collision_point)
		resource_hover_holder.visible = true
		if grid_map.can_place_resource(grid_pos, resource_hover_holder.shape):
			color_transparent_mesh_instance(resource_hover_holder, 1)
			#print("dziala")
		else:
			#print("nie dziala")
			color_transparent_mesh_instance(resource_hover_holder, 2)
		var place_pos = grid_map.map_to_local(grid_pos)
		#print(grid_pos)
		place_pos.y=2.5
		place_pos.x+=1
		place_pos.z+=1
		resource_hover_holder.position=place_pos
	else:
		#print("nie dziala raycast")
		resource_hover_holder.visible = false


#Signal to enter build mode
func _on_tetris_build_button_pressed() -> void:
	if walls_build:
		walls_build = false
	else:
		walls_build = true
		

#called in _progress updates mesh that is hover for block placement
func update_hover_mesh(good_place:bool) -> void:
	var mesh_lib = grid_map.mesh_library
	if not mesh_lib:
		return  # Upewnij się, że mesh_library istnieje
	for i in range(hover.size()):
		if hover[i] and good_place:
			hover[i].mesh = mesh_lib.get_item_mesh(11)
		elif hover[i] and not good_place:
			hover[i].mesh = mesh_lib.get_item_mesh(9)

#transforms shortest_path from gridmap placement to local 
func convert_path_to_local()-> void:
	#delete previous path
	if not short_path.is_empty():
		short_path = []
		
	#add start_end points to path (to be discussed)
	var path_start = grid_map.start_point
	path_start.x +=1
	var path_end = grid_map.end_point
	path_end.x -=1
	short_path.append(grid_map.map_to_local(path_start))
	
	#we add grid_map.shortest_path to short_path changing it to local needs 
	for vect in grid_map.shortest_path:
			vect.y += 1
			short_path.append(grid_map.map_to_local(vect))
	short_path.append(grid_map.map_to_local(path_end))


func update_label_build_time():
	build_time_label.text = "Time for building: " + str(ceil(build_timer.time_left)) + "s"


func _on_build_timer_timeout() -> void:
	is_build_phase = false
	build_time_label.text = "Build phase ended!"
	current_cam_index = 0
	set_camera()
	switch_label_timer.start()
	if tower_hover_holder:
		tower_hover_holder.free()
	if resource_hover_holder:
		resource_hover_holder.free()
	if !enemy_spawner.wave_in_progress:
		enemy_spawner.start_wave()
		UI.bottom_panel.visible = false
		UI.unpress_all_buttons()
		for h in hover:
			h.visible = false

#resets build timer and enables buttons
func reset_build_timer():
	is_build_phase = true
	UI.show_first_panel()
	UI.bottom_panel.visible = true
	build_timer.start()

#when end wave signal is recived resets build timer
func _on_enemy_spawner_wave_ended() -> void:
	#print("Przekazano sygnal")
	enemy_spawner.current_wave+=1
	enemy_spawner.update_wave_enemy_count()
	UI.update_enemy_count_labels(enemy_spawner.basic_enemies_per_wave, enemy_spawner.fast_enemies_per_wave, 0)
	if game:
		reset_build_timer()

#changes label 2 s after wave started
func _on_switch_label_timer_timeout() -> void:
	build_time_label.text = "Current wave: " + str(enemy_spawner.current_wave)
	
func take_damage(dmg) -> void:
	current_health = current_health-dmg
	#print("Current health z maina:",current_health)
	UI.update_hearts()
	if current_health <= 0:
		print("GAMEOVER GG")
		game = false
		GameOver.visible = true
		$CanvasLayer/UI/GameOverScreen/VBoxContainer/GameOverText.text = "Game Over!\nYou failed at\n wave number\n %d." % wave_number
		$CanvasLayer/UI/GameOverScreen/VBoxContainer/MainMenu_button.disabled = false
		$CanvasLayer/UI/GameOverScreen/VBoxContainer/PlayAgain_button.disabled = false
		for i in range(get_node("Tower Holder").get_child_count()):
			var tower = get_node("Tower Holder").get_child(i)
			tower.get_node("MobDetector").get_child(0).disabled=true
			tower.can_shoot = false
		for i in range(get_node("Resource Holder").get_child_count()):
			var building = get_node("Resource Holder").get_child(i)
			building.get_node("Timer").stop()
			building.generator_on = false
			
