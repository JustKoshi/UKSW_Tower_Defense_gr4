extends Node3D

#List containing all cameras and current cam index
@onready var cameras = [$"Main Camera", $"Top Camera", $"Front camera", $"Front camera2", $"Resource Camera",$"Debug camera",$"Ship/Path3D2/PathFollow3D/SM_Galleon_MI_Base_Wood_Dark_0/Debug camera2"]

#variable to contain main GridMap
@onready var grid_map = $GridMap

#variables to contain build time logoic and ui label informing about build time
@onready var build_timer = $"Build Timer"
@onready var build_time_label = $"CanvasLayer/UI/Build time Label"
@onready var switch_label_timer = $"Switch Label Timer"
@onready var sprite_timer = $"Sprite Timer"
#variable to contain raycast to detect clicks in build mode
@onready var raycast = $"Top Camera/RayCast3D"

#variable to contain Enemy Path Spawner
@onready var enemy_spawner = $"Enemy Spawner"

@onready var UI = $CanvasLayer/UI
@onready var menu: Control = $CanvasLayer/Menu
@onready var GameOver = $CanvasLayer/UI/GameOverScreen
@onready var how_to_play: Control = $"CanvasLayer/Menu/How to Play"
@onready var pause_menu: Control = $"CanvasLayer/Pause Menu"

@onready var resource_holder: Node = $"Resource Holder"

@onready var wave_start_sound: AudioStreamPlayer = $"SFX and music/Wave start"
@onready var hit: AudioStreamPlayer = $"SFX and music/Hit"
@onready var fanfare: AudioStreamPlayer = $"SFX and music/Fanfare"
@onready var music: AudioStreamPlayer = $"SFX and music/Music"
@onready var sad_trombone: AudioStreamPlayer = $"SFX and music/Sad trombone"
@onready var quack_sound: AudioStreamPlayer = $"SFX and music/Quack_sound"


var NormalTowerScene = preload("res://Scenes/normal_tower_lvl_1.tscn")
var FreezeTowerScene = preload("res://Scenes/Freeze_tower_lvl_1.tscn")
var AOETowerScene = preload("res://Scenes/aoe_tower.tscn")
var Lumbermill = preload("res://Scenes/lumbermill.tscn")
var Mine = preload("res://Scenes/mine.tscn")
var Windmill = preload("res://Scenes/windmill.tscn")
var Tavern = preload("res://Scenes/tavern.tscn")
var Ship = preload("res://Scenes/ship.tscn")
var duck = preload("res://Scenes/duck.tscn")

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
var resource_to_hover = 0#0 for none, 1 for lumbermill, 2 for mine, 3 for windmill, 4 for tavern
var resource_shape

#Vars for ship fadeout func
var value = 1.0  # Startowa wartość
var duration = 2.0  # Czas w sekundach
var time_passed = 0.0  # Licznik czasu


#sprite timer variables
const MIN_TIME = 1
const MAX_TIME = 15


var current_cam_index = 0
var coordinates_check_mode = false
var hover = [null, null, null, null] #array that holds blocks for hover. 4 couse very tetris block size = 4
var short_path = [] #array that holds shortest path converted to local

var tower_hover_holder:MeshInstance3D = null#Object that holds tower instance that is now currently selected and might be placed
var resource_hover_holder:MeshInstance3D = null
var duck_holder = null

#setting up the database and stats:
var database: SQLite
var stats = {
	"placed_towers" : 0,
	"placed_tetris_blocks" : 0,
	"generated_wood" : 0,
	"generated_stone" : 0,
	"generated_wheat" : 0,
	"generated_beer" : 0,
	"killed_normal_enemies" : 0,
	"killed_fast_enemies" : 0,
	"killed_pyro_enemies" : 0,
	"killed_boss_enemies" : 0,
	"used_powerups" : 0,
	"defeated_waves" : 0,
	"times_played" : 0,
	"time_in_game" : 0,
	"has_1000_res" : 0,
	"map_covered" : 0,
	"lost_health" : 0,
	"minigames_won" : 0,
	"easter_egg" : 0
}
var start_time
var end_time

#achievement related variables
var has_1000_res = 0
var map_covered = 0
var easter_egg = 0

#resource counter:
var game_resources = {
	"wood": 0,
	"stone": 0,
	"wheat": 0,
	"beer": 0,
	"used_workers": 0,
	"workers": 0
}
var max_health = 15
var current_health
var game = false
var game_over = false

var wave_number = 1
var is_build_phase = true

var number_of_tetris_placed

var texture_png = load("res://Resources/Towers/hexagons_medieval.png")
var red_mat = StandardMaterial3D.new()
var normal_mat = StandardMaterial3D.new()
var red_mat_range = StandardMaterial3D.new()
var normal_mat_range = StandardMaterial3D.new()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_time = Time.get_unix_time_from_system()
	#starting resources
	game_resources.wood = 10
	game_resources.stone = 10
	
	#opening database
	database = SQLite.new()
	database.path = "res://data.db"
	database.open_db()
	var main_table = {
		"id" : {"data_type" : "int", "primary_key" : true, "not_null" : true, "auto_increment" : true},
		"placed_towers" : {"data_type" : "int"},
		"placed_tetris_blocks" : {"data_type" : "int"},
		"generated_wood" : {"data_type" : "int"},
		"generated_stone" : {"data_type" : "int"},
		"generated_wheat" : {"data_type" : "int"},
		"generated_beer" : {"data_type" : "int"},
		"killed_normal_enemies" : {"data_type" : "int"},
		"killed_fast_enemies" : {"data_type" : "int"},
		"killed_pyro_enemies" : {"data_type" : "int"},
		"killed_boss_enemies" : {"data_type" : "int"},
		"used_powerups" : {"data_type" : "int"},
		"defeated_waves" : {"data_type" : "int"},
		"times_played" : {"data_type" : "int"},
		"time_in_game" : {"data_type" : "int"},
		"has_1000_res" : {"data_type" : "int"},
		"map_covered" : {"data_type" : "int"},
		"lost_health" : {"data_type" : "int"},
		"minigames_won" : {"data_type" : "int"},
		"easter_egg" : {"data_type" : "int"}
	}
	database.create_table("Stats",main_table)
	var row = database.select_rows("Stats","id=1",["*"])
	if row.is_empty():
		database.insert_row("Stats",stats)
	
	current_health = max_health
	game = false
	GameOver.visible = false
	$CanvasLayer/UI/GameOverScreen/VBoxContainer/MainMenu_button.disabled = true
	number_of_tetris_placed = 0
	game_resources.workers = 2
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
	UI.update_enemy_count_labels(enemy_spawner.basic_enemies_per_wave, enemy_spawner.fast_enemies_per_wave, enemy_spawner.boss_enemies_per_wave, enemy_spawner.pyro_enemies_per_wave)
	duck_holder = duck.instantiate()
	add_child(duck_holder)
	duck_holder.position = Vector3(0,0,30)
	
	#testing chagnes: 
	#enemy_spawner.current_wave = 5
	game_resources.wood = 999
	game_resources.stone = 999
	game_resources.wheat = 999
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#testing:
	#print("fala: ",enemy_spawner.current_wave)
	#enemy_spawner.update_wave_enemy_count()
	#enemy_spawner.current_wave += 1
	
	update_resource_timers()
	if Input.is_action_just_pressed("Camera_F1") and game:
		if current_cam_index >0 :
			current_cam_index -= 1
		current_cam_index = current_cam_index%3
		set_camera()
	
	elif Input.is_action_just_pressed("Camera_F2") and game:
		current_cam_index += 1
		current_cam_index = current_cam_index%5
		set_camera()
		
	elif Input.is_action_just_pressed("Camera_F9") and game:
		current_cam_index = 1
		set_camera()
		if !coordinates_check_mode:
			coordinates_check_mode = true
		else:
			coordinates_check_mode = false
			
	elif Input.is_action_just_pressed("pause") and game:
		get_tree().paused = true
		UI.visible = false
		pause_menu.visible = true
		load_data_to_database()
		
	
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
	if aoe_tower_build:
		tower_to_hover = 3
		hover_tower(tower_to_hover)
		set_build_cam()
	if not normal_tower_build and not freeze_tower_build and not aoe_tower_build:
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
	if wheat_build:
		set_resource_cam()
		resource_to_hover = 3
		hover_resource(resource_to_hover)
	if beer_build:
		set_resource_cam()
		resource_to_hover = 4
		hover_resource(resource_to_hover)
	if not wood_build and not stone_build and not wheat_build and not beer_build:
		resource_to_hover = 0
	if is_build_phase:
		update_label_build_time()
	if game_resources.wood >=1000 or game_resources.stone >=1000 or game_resources.wheat >=1000 or game_resources.beer >=1000:
		has_1000_res = 1
	if number_of_tetris_placed >=15:
		map_covered = 1
	if game and is_build_phase:
		ship_sailin(delta)
	elif game:
		if value > 0:
			time_passed += delta
			value = clamp(1.0 - time_passed / duration, 0.0, 1.0)
			ship_fadeout()
	
	
	if not game:
		get_node("Main Camera").angle += 0.1 * delta

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
	if (normal_tower_build or freeze_tower_build or aoe_tower_build) and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
			place_tower_on_click(hovering_tower)
	if (wood_build or stone_build or wheat_build or beer_build) and event is InputEventMouseButton:
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
	current_cam_index = 4
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
	
		#print("Collision point: ", result)
	if result.size() > 0:
		return result.position  # Return collision point
	else:
		return null  #No collison

#function places block on raycast position
func place_block_on_click():
	var collision_point = get_collision_point()
	var needed_res = 3*(number_of_tetris_placed + 1)
	#checking if raycast detected any block if so place block on gridmap
	if collision_point != null and is_enough_resources(needed_res,needed_res,0,0,0):
		var grid_pos = grid_map.local_to_map(collision_point)
		if grid_map.can_place_tetris_block(grid_pos,grid_map.current_shape):
			number_of_tetris_placed += 1
			stats.placed_tetris_blocks += 4
			game_resources.wood -= needed_res
			game_resources.stone -= needed_res
		grid_map.place_tetris_block(grid_pos, grid_map.current_shape)
		convert_path_to_local()
		enemy_spawner.set_path(short_path)


#function places tower on raycast position
func place_tower_on_click(tower_type:int):
	if tower_hover_holder != null:
		tower_hover_holder.free()#deleting hover tower before getting collision point
	var collision_point = get_collision_point()
	var tower
	if(tower_type==1):
		tower = NormalTowerScene.instantiate()
	elif(tower_type==2):
		tower = FreezeTowerScene.instantiate()
		tower.get_node("MobDetector").get_child(0).disabled=false
	elif(tower_type==3):
		tower = AOETowerScene.instantiate()
	self.get_node("Tower Holder").add_child(tower)
	var needed_wood = tower.wood_to_upgrade[0]
	var needed_stone = tower.stone_to_upgrade[0]
	var needed_wheat = tower.wheat_to_upgrade[0]
	#checking if raycast detected any block if so place block on gridmap
	if collision_point != null and grid_map.can_place_tower(collision_point) and is_enough_resources(needed_wood,needed_stone,needed_wheat,0,0):
	#if tower can be placed instantiate tower and change its cordinates and turn off range and turning of hover transparency
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
		if tower_type == 3:
			tower.set_surface_override_material(1,mat_dup)
		tower.get_node("MobDetector").visible=false
		tower.connect("tower_info",UI._on_normal_tower_lvl_1_tower_info)
		tower_type*=3#This change is for the save/load
		grid_map.place_tower_in_tilemap(collision_point, tower_type)
		#print("Added tower in position: ",grid_pos)
		game_resources.wood -= needed_wood
		game_resources.stone -= needed_stone
		game_resources.wheat -= needed_wheat
		tower_hover_holder = null
		hovering_tower = 0
		stats.placed_towers += 1
	else:
		tower.queue_free()

#function that hover towers over the map showing where it can be placed and its range
func hover_tower(_tower_type:int):
	var collision_point = get_collision_point()
	var needed_wood = 0
	var needed_stone = 0
	var needed_wheat = 0
	if tower_to_hover == 1:
		needed_wood = 20
		needed_stone = 20
	elif tower_to_hover == 2:
		needed_wood = 30
		needed_stone = 30
	elif tower_to_hover == 3:
		needed_wood = 50
		needed_stone = 50
	if tower_hover_holder==null or tower_to_hover!=hovering_tower:
		#if there was no hover instantiate 1 hover tower and making its opacity = 0.5
		if(tower_to_hover==1):
			tower_hover_holder = NormalTowerScene.instantiate()
			hovering_tower = 1
		elif(tower_to_hover==2):
			tower_hover_holder = FreezeTowerScene.instantiate()
			hovering_tower = 2
		elif(tower_to_hover==3):
			tower_hover_holder = AOETowerScene.instantiate()
			hovering_tower = 3
		tower_hover_holder.can_shoot=false
		tower_hover_holder.get_node("MobDetector").visible = true
		get_node("Tower Holder").add_child(tower_hover_holder)
		tower_hover_holder.set_surface_override_material(0,normal_mat)
		if tower_to_hover == 1:
			tower_hover_holder.set_surface_override_material(1,normal_mat)
		if tower_to_hover == 2:
			tower_hover_holder.get_node("Mage").visible = false
		if tower_to_hover == 3:
			tower_hover_holder.set_surface_override_material(1,normal_mat)
	if collision_point != null:
		tower_hover_holder.visible=true
		var grid_pos = grid_map.local_to_map(collision_point)
		var place_pos = grid_map.map_to_local(grid_pos)
		place_pos.y=4.5
		tower_hover_holder.position=place_pos#changing tower position after cursor
		if grid_map.can_place_tower(collision_point) and is_enough_resources(needed_wood,needed_stone,needed_wheat,0,0):
			#if tower can be placed change its color to normal
			#print("Normal tower\t\twood: ",needed_wood," stone: ",needed_stone)
			tower_hover_holder.get_node("MobDetector").get_child(1).set_surface_override_material(0,normal_mat_range)
			tower_hover_holder.set_surface_override_material(0,normal_mat)
			if tower_to_hover == 1:
				tower_hover_holder.set_surface_override_material(1,normal_mat)
			if tower_to_hover == 3:
				tower_hover_holder.set_surface_override_material(1,normal_mat)
		else:
			#if it cant be placed change its color to red
			#print("Red tower")
			tower_hover_holder.get_node("MobDetector").get_child(1).set_surface_override_material(0,red_mat_range)
			tower_hover_holder.set_surface_override_material(0,red_mat)
			if tower_to_hover == 1:
				tower_hover_holder.set_surface_override_material(1,red_mat)
			elif tower_to_hover == 3:
				tower_hover_holder.set_surface_override_material(1,red_mat)
	else:
		#free hover if cursor is out of gridmap
		tower_hover_holder.queue_free()
		tower_hover_holder = null
	
#function creates block hover on raycast position
func update_hover_tetris():
	var collision_point = get_collision_point()
	if collision_point != null and walls_build:
		var grid_pos = grid_map.local_to_map(collision_point)
		var grid_pos_f = Vector3(grid_pos.x, grid_pos.y, grid_pos.z)
		var needed_res = 2*(number_of_tetris_placed + 1)
		if grid_map.can_place_tetris_block(grid_pos,grid_map.current_shape) and is_enough_resources(needed_res,needed_res,0,0,0):
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
	if object is Windmill:#bardzo tymczasowy i brzydki fix
		for i in range(34):
			if i==16 || i==33:
				var mat = object.get_surface_override_material(i)
				var mat_dupe = mat.duplicate()
				mat_dupe.flags_transparent = true
				match color:
					1:
						mat_dupe.albedo_color = Color(1,1,1,0.5)
					2:
						mat_dupe.albedo_color = Color(1,0,0,0.5)
					3:
						mat_dupe.albedo_color = Color("#836d4b")
						mat_dupe.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED
				object.set_surface_override_material(i,mat_dupe)
			else:
				var mat = object.get_surface_override_material(i)
				var mat_dupe = mat.duplicate()
				mat_dupe.flags_transparent = true
				match color:
					1:
						mat_dupe.albedo_color = Color(1,1,1,0.5)
					2:
						mat_dupe.albedo_color = Color(1,0,0,0.5)
					3:
						mat_dupe.albedo_color = Color("#e5e761")
						mat_dupe.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED
				object.set_surface_override_material(i,mat_dupe)
			
		for i in range(object.get_surface_override_material_count()-3,object.get_surface_override_material_count()):
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
	else:
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
		if child.generator_on and !child.disabled:
			update_resource_stats(child)
			child.get_node("Timer").start()
			child.generator_on = false
			if child.generation_depleted:
				game_resources[child.resource_type] += 1#polowa wartosci
			else:
				game_resources[child.resource_type] += 2


func place_resource_on_click(resource_type:int):
	if resource_hover_holder != null:
		resource_hover_holder.free()
	var collision_point = get_collision_point()
	var building
	#checking if raycast detected any block if so place block on gridmap
	if collision_point != null and is_enough_resources(0,0,0,0,1):
		var grid_pos = grid_map.local_to_map(collision_point)
		if grid_map.can_place_resource(grid_pos, resource_shape):
			if resource_type == 1:
				building = Lumbermill.instantiate()
			elif resource_type == 2:
				building = Mine.instantiate() 
			elif resource_type == 3:
				building = Windmill.instantiate()
			elif resource_type == 4:
				building = Tavern.instantiate()
			else:
				return
			var place_pos = grid_map.map_to_local(grid_pos)
			place_pos.y=2.5
			if resource_type in [1,2]:
				place_pos.x+=1
				place_pos.z+=1
			#print(place_pos)
			building.position=place_pos
			grid_map.place_resource_in_tilemap(collision_point, hovering_resource)
			#	building.generation_depleted = true
			get_node("Resource Holder").add_child(building)
			color_transparent_mesh_instance(building,3)
			check_resource_generation_req()
			
			#print("Added lumbermill in position: ",grid_pos)
			game_resources.used_workers += 1
			resource_hover_holder=null
			hovering_resource = 0
			building.connect("resource_info", UI._on_resource_info)

func check_resource_generation_req():
	var shifts = [Vector3(-4,0,0),Vector3(4,0,0),Vector3(0,0,-4),Vector3(0,0,4)]
	var tavern_shift = Vector3(-2,0,-2)#distance from corretly placed tavern to its correctly placed windmill
	var windmill_shift = Vector3(-3,0,-3)
	var node = get_node("Resource Holder")
	for r in node.get_child_count():
		var resource = node.get_child(r)
		if resource is Tavern or resource is Windmill:
			resource.generation_depleted = true
		else:
			resource.generation_depleted = false
		for r2 in node.get_child_count():
			var resource2 = node.get_child(r2)
			if resource==resource2:
				continue
			for i in shifts:
				if resource is Lumbermill:
					if resource.transform.origin+i==resource2.transform.origin and resource2 is Mine:
						resource.generation_depleted = true
						resource2.generation_depleted = true
				if resource is Mine:
					if resource.transform.origin+i==resource2.transform.origin and resource2 is Lumbermill:
						resource.generation_depleted = true
						resource2.generation_depleted = true
				if resource is Tavern:
					if resource2 is Windmill and resource2.transform.origin == resource.transform.origin+tavern_shift:
						resource.generation_depleted = false
				if resource is Windmill:
					if resource2 is Mine or resource2 is Lumbermill:
						#print("farma:", resource.transform.origin, " drugie: ", resource2.transform.origin )
						if resource2.transform.origin+windmill_shift == resource.transform.origin:
							resource.generation_depleted = false
					elif resource2 is Windmill:
						if resource2.transform.origin+tavern_shift == resource.transform.origin:
							resource.generation_depleted = false
					elif resource2 is Tavern:
						if resource.transform.origin == resource2.transform.origin+tavern_shift:
							resource.generation_depleted = false
		if resource.generation_depleted:
			resource.get_node("exclamation_mark").visible = true
		else:
			resource.get_node("exclamation_mark").visible = false

func resource_sprite_popup()->void:
	var child_count = get_node("Resource Holder").get_child_count()
	if child_count > 0:
		var res = get_node("Resource Holder").get_child(randi()%child_count)
		if res.disabled:#If the random chosenn building is alreaddy disabled then the minigame wont triggger that round
			return
		res.sprite_phase = true
		res.get_node("Sprite3D").get_node("sprite_countdown").start()

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
		elif resource_type == 3:
			resource_hover_holder = Windmill.instantiate()
			hovering_resource = 3
			resource_shape = resource_hover_holder.shape
			resource_hover_holder.generator_on = false
		elif resource_type == 4:
			resource_hover_holder = Tavern.instantiate()
			hovering_resource = 4
			resource_shape = resource_hover_holder.shape
			resource_hover_holder.generator_on = false
		else:
			return
		resource_hover_holder.game_script = self
		get_node("Resource Holder").add_child(resource_hover_holder)
	if collision_point != null:
		var grid_pos = grid_map.local_to_map(collision_point)
		resource_hover_holder.visible = true
		check_resource_generation_req()
		if grid_map.can_place_resource(grid_pos, resource_hover_holder.shape) and is_enough_resources(0,0,0,0,1):
			color_transparent_mesh_instance(resource_hover_holder, 1)
			
			
			#print("dziala")
		else:
			#print("nie dziala")

			color_transparent_mesh_instance(resource_hover_holder, 2)
		var place_pos = grid_map.map_to_local(grid_pos)
		#print(grid_pos)
		place_pos.y=2.5
		if hovering_resource in [1,2]:
			place_pos.x+=1
			place_pos.z+=1
		
		resource_hover_holder.position=place_pos
	else:
		#print("nie dziala raycast")
		resource_hover_holder.queue_free()
		resource_hover_holder = null

func ship_sailin(delta: float)->void:
	var move_speed = 20
	get_node("Ship/Path3D2/PathFollow3D").progress +=move_speed*delta

func ship_fadeout() -> void:
	var mesh = get_node("Ship/Path3D2/PathFollow3D/SM_Galleon_MI_Base_Wood_Dark_0").mesh
	for i in range(mesh.get_surface_count()):
		var mat = mesh.surface_get_material(i)
		var mat_dupe = mat.duplicate()
		mat_dupe.flags_transparent = true
		mat_dupe.albedo_color.a = value  
		mesh.surface_set_material(i, mat_dupe)

func ship_reset()->void:
	var mesh = get_node("Ship/Path3D2/PathFollow3D/SM_Galleon_MI_Base_Wood_Dark_0").mesh
	for i in range(mesh.get_surface_count()):
		var mat = mesh.surface_get_material(i)
		var mat_dupe = mat.duplicate()
		mat_dupe.albedo_color.a = 1  
		mat_dupe.flags_transparent = false
		mat_dupe.transparency=BaseMaterial3D.TRANSPARENCY_DISABLED
		mesh.surface_set_material(i, mat_dupe)
		
		get_node("Ship/Path3D2/PathFollow3D").progress = 0
		value=1.0
		time_passed = 0.0

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
		return  # Upewnij sie, ze mesh_library istnieje
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
	var new_end = grid_map.map_to_local(path_end)
	new_end.x+=1
	short_path.append(new_end)

func update_label_build_time():
	build_time_label.text = "Time for building: " + str(ceil(build_timer.time_left)) + "s"
			
func prepare_wave() -> void:
	is_build_phase = false
	build_time_label.text = "Build phase ended!"
	current_cam_index = 0
	set_camera()
	switch_label_timer.start()
	if tower_hover_holder != null:
		tower_hover_holder.free()
	if resource_hover_holder != null:
		resource_hover_holder.free()
	if !enemy_spawner.wave_in_progress:
		enemy_spawner.start_wave()
		wave_start_sound.play()
		UI.bottom_panel.visible = false
		UI.unpress_all_buttons()
		UI._on_X_button()
		UI._on_X_button_r()
		for h in hover:
			h.visible = false
	UI.switch_skip_button_visiblity()

#function that checks whether you can buy something or you have not enough resources
func is_enough_resources(wo:int, st:int, wh:int, be:int, pe:int) -> bool:
	if game_resources.wood >= wo and game_resources.stone >= st and game_resources.wheat >= wh and game_resources.beer >= be and game_resources.workers >= game_resources.used_workers + pe:
		return true
	else:
		return false

#resets build timer and enables buttons
func reset_build_timer():
	is_build_phase = true
	ship_reset()
	UI.show_first_panel()
	UI.bottom_panel.visible = true
	build_timer.start()
	sprite_timer.stop()

#when end wave signal is recived resets build timer
func _on_enemy_spawner_wave_ended() -> void:
	#print("Przekazano sygnal")
	if game:
		fanfare.play()
	if enemy_spawner.current_wave == 5:
		$"CanvasLayer/UI/Bottom_panel/Resource buildings/HBoxContainer/Wheat building".disabled = false
		$"CanvasLayer/UI/Bottom_panel/Resource buildings/HBoxContainer/Workers".disabled = false
		for button in UI.locked_buttons:
			for child in button.get_children():
				if child is TextureRect:
					if not UI.original_positions.has(child):
						UI.original_positions[child] = child.position.y
				var target_position = child.position
				if not button.disabled:
					target_position.y = UI.original_positions[child]
					child.position = target_position
		game_resources.workers += 1
	elif enemy_spawner.current_wave == 10:
		$"CanvasLayer/UI/Bottom_panel/Resource buildings/HBoxContainer/Beer building".disabled = false
		for child in $"CanvasLayer/UI/Bottom_panel/Resource buildings/HBoxContainer/Beer building".get_children():
			if child is TextureRect:
				if not UI.original_positions.has(child):
					UI.original_positions[child] = child.position.y
			var target_position = child.position
			target_position.y = UI.original_positions[child]
			child.position = target_position
	enemy_spawner.current_wave += 1
	enemy_spawner.update_wave_enemy_count()
	UI.update_enemy_count_labels(enemy_spawner.basic_enemies_per_wave, enemy_spawner.fast_enemies_per_wave, enemy_spawner.boss_enemies_per_wave, enemy_spawner.pyro_enemies_per_wave)
	UI.enemies_scaling()
	stats.defeated_waves += 1
	if game:
		reset_build_timer()
		UI.switch_skip_button_visiblity()
		sprite_timer.start()

#changes label 2 s after wave started
func _on_switch_label_timer_timeout() -> void:
	build_time_label.text = "Current wave: " + str(enemy_spawner.current_wave)
	
#Function that happens when enemies deal damage to our gate and checks for game_over possibility
func take_damage(dmg) -> void:
	if game:
		hit.play()
	current_health = current_health-dmg
	if game:
		stats.lost_health += dmg
	#print("Current health z maina:",current_health)
	UI.update_hearts()
	if current_health <= 0 and game:
		print("GAMEOVER GG")
		game = false
		music.stop()
		sad_trombone.play()
		GameOver.visible = true
		$CanvasLayer/UI/GameOverScreen/VBoxContainer/GameOverText.text = "Game Over!\nYou failed at\n wave number\n %d." % enemy_spawner.current_wave
		$CanvasLayer/UI/GameOverScreen/VBoxContainer/MainMenu_button.disabled = false
		for i in range(get_node("Tower Holder").get_child_count()):
			var tower = get_node("Tower Holder").get_child(i)
			tower.get_node("MobDetector").get_child(0).disabled=true
			tower.can_shoot = false
		for i in range(get_node("Resource Holder").get_child_count()):
			var building = get_node("Resource Holder").get_child(i)
			building.get_node("Timer").stop()
			building.generator_on = false
		stats.times_played += 1
		load_data_to_database()
			
func _on_skip_button_pressed() -> void:
	var remaining_time = build_timer.time_left
	var adding_resources = int(remaining_time/3)
	var adding_beer = int(remaining_time/5)
	for i in range(get_node("Resource Holder").get_child_count()):
		var child = get_node("Resource Holder").get_child(i)
		if !child.disabled:
			update_resource_stats(child)
			if not child.resource_type == "beer":
				if child.generation_depleted:
					game_resources[child.resource_type] += 1*adding_resources#polowa wartosci
				else:
					game_resources[child.resource_type] += 2*adding_resources
			else:
				if child.generation_depleted:
					game_resources[child.resource_type] += 1*adding_beer#polowa wartosci
				else:
					game_resources[child.resource_type] += 2*adding_beer
	build_timer.stop()
	
	#after skip the sprite minigame triggers automatically
	#sprite_timer.stop()
	#resource_sprite_popup()
	
	prepare_wave()
	
	get_node("Ship/Path3D2/PathFollow3D").progress = 565.87

func start_game():
	game = true
	print("1")
	build_timer.start()
	UI.visible = true
	menu.visible = false

func _on_play_pressed() -> void:
	start_game()
	if how_to_play.visible:
		how_to_play.visible = false
		value = 1.0
		time_passed = 0.0

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_continue_pressed()->void:
	get_tree().paused = false
	pause_menu.visible = false
	UI.visible = true


#fuction to buy workers
func buy_workers() -> void:
	game_resources.wheat -= (30 * (game_resources.workers - 2))
	game_resources.workers += 1
	UI._on_no_pressed()

func rand_builiding_to_destroy():
	return randi_range(0, resource_holder.get_child_count()-1)

func destoy_resource_building():
	if resource_holder.get_child_count()>0:
		var resource = resource_holder.get_child(rand_builiding_to_destroy())
		game_resources.used_workers-=1
		game_resources.workers-=1
		var col_point = resource.position
		#print(col_point)
		var grid_pos = grid_map.local_to_map(col_point)
		var tile_pos = Vector3(grid_pos.x+10, grid_pos.y, grid_pos.z+5)
		for i in resource.shape:
			grid_map.castle_state[tile_pos.z-i.z][tile_pos.x-i.x] = 0
		resource.free()
		check_resource_generation_req()

func update_enemy_killed_stats(enemy_type:String) ->void:
	match enemy_type:
		"Basic Enemy":
			stats.killed_normal_enemies += 1
		"Fast Enemy":
			stats.killed_fast_enemies += 1
		"Pyro":
			stats.killed_pyro_enemies += 1
		"Boss Enemy":
			stats.killed_boss_enemies += 1

func update_resource_stats(resource) ->void:
	if resource.generation_depleted:
		match resource.resource_type:
			"wood":
				stats.generated_wood += 1
			"stone":
				stats.generated_stone += 1
			"wheat":
				stats.generated_wheat += 1
			"beer":
				stats.generated_beer += 1
	else:
		match resource.resource_type:
			"wood":
				stats.generated_wood += 2
			"stone":
				stats.generated_stone += 2
			"wheat":
				stats.generated_wheat += 2
			"beer":
				stats.generated_beer += 2
	
func load_data_to_database() -> void:
	end_time = Time.get_unix_time_from_system()
	stats.time_in_game = (end_time-start_time)/60
	start_time = Time.get_unix_time_from_system()
	var stat
	stat = database.select_rows("Stats","id=1",["*"])
	for i in stats:
		if i == "has_1000_res":
			if stat[0][i] == 0:
				stat[0][i] = has_1000_res
		if i == "map_covered":
			if stat[0][i] == 0:
				stat[0][i] = map_covered
		if i == "easter_egg":
			if stat[0][i] == 0:
				stat[0][i] = easter_egg
		else:
			stat[0][i] += stats[i]
			stats[i] = 0
	print(stat[0])
	database.update_rows("Stats","id=1",stat[0])
	
func quack():
	quack_sound.play()


func _on_sprite_timer_timeout()->void:
	resource_sprite_popup()
	var random_interval = randf_range(MIN_TIME, MAX_TIME)
	sprite_timer.wait_time = random_interval
	

#func save_gamestate()->void:
#	var game_state
#	var file = FileAccess.open(, FileAccess.WRITE)
