extends MeshInstance3D

var stone = preload("res://Scenes/stone.tscn")
var aoe = [0.25,0.33,0.5]
var damage = [75,85,100]
var health = [3,3,4]
var tower_range = [3,3,4]
var level = 1
var firerate = [0.25,0.25,0.33]
var title = "AOE Tower"
var current_health
var enemies = []
var current_enemy
var can_shoot = true
var is_targeted = false

var return_wood
var return_stone
var repair_wood
var repair_stone
var wood_to_upgrade = [50,75,125,0]
var stone_to_upgrade = [50,75,125,0]
var wheat_to_upgrade = [0,100,150,0]

var mesh_lvl2 = load("res://Resources/Towers/AOETower/AOETower_lvl2.obj")
var mesh_lvl3 = load("res://Resources/Towers/AOETower/AOETower_lvl3.obj")

var stone_texture = preload("res://Resources/Towers/Stone/Gravel040_1K-JPG_Color.jpg")
var stone_lvl2 = StandardMaterial3D.new()
var stone_lvl3 = StandardMaterial3D.new()

signal tower_info(object)

@onready var grid_map = self.get_parent().get_parent().grid_map

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stone_lvl2.albedo_texture = stone_texture
	stone_lvl3.albedo_texture = stone_texture
	stone_lvl2.albedo_color = Color(0,1,0)
	stone_lvl3.albedo_color = Color(1,0,0)
	current_health = health[level-1]
	return_wood = 10
	return_stone = 10
	repair_wood = 15
	repair_stone = 15
	get_node("MobDetector").get_child(0).shape.radius = 2*tower_range[level-1]+1
	get_node("MobDetector").get_child(1).mesh.top_radius = 2*tower_range[level-1]+1
	get_node("MobDetector").get_child(1).mesh.bottom_radius = 2*tower_range[level-1]+1


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	set_target(enemies)
	if current_enemy != null:
		look_at(current_enemy.global_position)
		self.rotation.x=0
		self.rotation.y+=135
	if is_instance_valid(current_enemy):
		if can_shoot:
			get_node("arm").get_node("AnimationPlayer").play("catapult_arm_blueAction_001")
			$arm/Animation_time.start()
			can_shoot=false


func _on_mob_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		enemies.append(body)

#Deleting enemies from that list that left the range
func _on_mob_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		enemies.erase(body)

#Function that checks which enemy is closer to castle and makes it a priority target
func set_target(targets: Array) ->void:
	var temp_array = targets
	var current_target = null
	for i in temp_array:
		if current_target==null:
			current_target=i
		else:
			if i.get_parent().get_progress() > current_target.get_parent().get_progress():
				current_target=i
	current_enemy = current_target
	
	
func shooting() -> void:
	var new_stone = stone.instantiate()
	if level > 1:
		var mat = new_stone.get_child(0).get_surface_override_material(0)
		var mat_dup = mat.duplicate(true)
		if level == 2:
			mat_dup.albedo_color = Color(0,1,0)
		elif level == 3:
			mat_dup.albedo_color = Color(1,0,0)
		new_stone.get_child(0).set_surface_override_material(0,mat_dup)
	new_stone.target=current_enemy.get_node("Aim")
	new_stone.stone_damage=damage[level-1]
	get_node("Stones").add_child(new_stone)
	new_stone.global_position = $Aim2.global_position
	
func deal_aoe(progress,enemy) ->void:
	var close_range = [progress-1,progress+1]
	for i in enemies:
		if i.get_parent().progress > close_range[0] and i.get_parent().progress < close_range[1] and i!=enemy:
			i.take_damage(damage[level-1] * aoe[level-1])
	
#Resetting can_shoot after CD passed
func _on_shooting_cd_timeout() -> void:
	can_shoot=true
	
func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			#print("AOE Tower clicked!")
			emit_signal("tower_info",self)
			
func upgrade() ->void:
	#print("Upgrade normal")
	if level == 1:
		get_node("Damage CD").wait_time = 1/firerate[level]
		self.mesh = mesh_lvl2
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).mesh.top_radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).mesh.bottom_radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).position.y = -1.6
		get_node("arm").get_node("catapult_arm_blue").set_surface_override_material(1,stone_lvl2)
	if level == 2:
		get_node("Damage CD").wait_time = 1/firerate[level]
		self.mesh = mesh_lvl3
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.top_radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.bottom_radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).position.y = -1.38
		get_node("Damage CD").wait_time = 1/firerate[level]
		get_node("arm").get_node("catapult_arm_blue").set_surface_override_material(1,stone_lvl3)
	level += 1
	current_health = health[level-1]


func _on_animation_time_timeout() -> void:
	set_target(enemies)
	if current_enemy != null:
		shooting()
	$"Damage CD".start()
	
func take_damage(dmg: int) -> void:
	current_health-=dmg
	if current_health<=0 and (current_health+dmg) > 0:
		var col_point = self.position
		var grid_pos = grid_map.local_to_map(col_point)
		var tile_pos = Vector3(grid_pos.x+grid_map.map_size, grid_pos.y, grid_pos.z+grid_map.map_size)
		grid_map.tile_state[tile_pos.z][tile_pos.x] = 2
		queue_free()
