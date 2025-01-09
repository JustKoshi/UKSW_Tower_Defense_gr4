extends MeshInstance3D

var bullet = preload("res://Scenes/bullet.tscn")
var damage = [20,25,33]
var health = [4,5,6]
var tower_range = [2,2,3]
var level = 1
var firerate = [1,1.1,1.2]
var title = "Normal Tower"
var enemies = []
var current_enemy
var can_shoot = true

var return_wood
var return_stone
var wood_to_upgrade = [20,25,75,0]
var stone_to_upgrade = [20,25,75,0]
var wheat_to_upgrade = [0,25,75,0]

var mesh_lvl2 = load("res://Resources/Towers/normalTower lvl1/normal_tower_lvl2.obj")
var mesh_lvl3 = load("res://Resources/Towers/normalTower lvl1/normal_tower_lvl3.obj")

signal tower_info(object)

func _ready() -> void:
	return_wood = 4
	return_stone = 4
	get_node("MobDetector").get_child(0).shape.radius = 2*tower_range[level-1]+1
	get_node("MobDetector").get_child(1).mesh.top_radius = 2*tower_range[level-1]+1
	get_node("MobDetector").get_child(1).mesh.bottom_radius = 2*tower_range[level-1]+1
	
func _process(_delta: float) -> void:
	#print(get_node("MobDetector").get_child(0).shape.radius)
	#print(get_node("MobDetector").get_child(1).mesh.radius)
	set_target(enemies)
	if is_instance_valid(current_enemy):
		if can_shoot:
			shooting()
			can_shoot=false
			$"Shooting CD".start()


#Adding enemies to the list enemies[] that went into the range
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

#Shooting function
func shooting() -> void:
	var new_bullet = bullet.instantiate()
	if level > 1:
		for i in new_bullet.get_child(0).get_surface_override_material_count():
				if i>0:
					var mat = new_bullet.get_child(0).get_surface_override_material(i)
					var mat_dup = mat.duplicate(true)
					if level == 2:
						mat_dup.albedo_color = Color(0,1,0)
					elif level == 3:
						mat_dup.albedo_color = Color(1,0,0)
					new_bullet.get_child(0).set_surface_override_material(i,mat_dup)
	new_bullet.target=current_enemy.get_node("Aim")
	new_bullet.arrow_damage=damage[level-1]
	get_node("Bullets").add_child(new_bullet)
	new_bullet.global_position = $Aim2.global_position

#Resetting can_shoot after CD passed
func _on_shooting_cd_timeout() -> void:
	can_shoot=true

func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			#print("Normal Tower clicked!")
			emit_signal("tower_info",self)
			
func upgrade() ->void:
	#print("Upgrade normal")
	if level == 1:
		get_node("Shooting CD").wait_time = 1/firerate[level]
		self.mesh = mesh_lvl2
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).mesh.top_radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).mesh.bottom_radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).position.y = -1.6
	if level == 2:
		get_node("Shooting CD").wait_time = 1/firerate[level]
		self.mesh = mesh_lvl3
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.top_radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.bottom_radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).position.y = -1.38
	level += 1
