extends MeshInstance3D

var slow = [0.75,0.67,0.5]
var damage = [3,3,5]
var health = [3,4,7]
var tower_range= [1,1,1]
var level = 1
var firerate = [round_to_decimals(1/2.4,2),round_to_decimals(1/2.4,2),round_to_decimals(1/2.4,2)]
var current_health
var title = "Freeze Tower"
var enemies = []
var can_shoot = true
var is_targeted = false

var return_wood
var return_stone
var repair_wood
var repair_stone
var wood_to_upgrade = [25,30,90,0]
var stone_to_upgrade = [25,30,90,0]
var wheat_to_upgrade = [0,30,90,0]

var mesh_lvl2 = load("res://Resources/Towers/FreezeTower/building_tower_A_green.obj")
var mesh_lvl3 = load("res://Resources/Towers/FreezeTower/building_tower_A_red.obj")
var mage_lvl2 = load("res://Resources/Icons/green_heart.png")
var mage_lvl3 = load("res://Resources/Icons/Heart.png")

signal tower_info(object)

@onready var grid_map = self.get_parent().get_parent().grid_map

func _ready() -> void:
	current_health = health[level-1]
	return_wood = 6
	return_stone = 6
	repair_wood = 5
	repair_stone = 5
	get_node("MobDetector").get_child(0).shape.radius = 2*tower_range[level-1]+1
	get_node("MobDetector").get_child(1).mesh.top_radius = 2*tower_range[level-1]+1
	get_node("MobDetector").get_child(1).mesh.bottom_radius = 2*tower_range[level-1]+1

func _process(_delta: float) -> void:
	for i in enemies:
		if i.freezing == false:
			i.freezing = true
			i.change_speed(slow[level-1])
	if !enemies.is_empty():
		if can_shoot:
			deal_dmg()
			can_shoot=false
			$"Damage CD".start()

func _on_mob_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		enemies.append(body)
		if body.freezing == false:
				body.freezing = true
				body.change_speed(slow[level-1])
				

func _on_mob_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		enemies.erase(body)
		if body.freezing == true:
			body.freezing = false
			body.change_speed(1/slow[level-1])

func deal_dmg():
	for e in enemies:
		e.take_damage(damage[level-1])
	
#Resetting can_dmg after CD passed
func _on_damage_cd_timeout() -> void:
	can_shoot=true

func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			#print("Freeze Tower clicked!")
			emit_signal("tower_info",self)

func round_to_decimals(value: float, decimals: int) -> float:
	var factor = pow(10, decimals)
	return round(value * factor) / factor
	
func upgrade() ->void:
	#print("Upgrade freeze")
	var hat = get_node("Mage").get_node("Rig").get_child(0).get_node("Mage_Hat").get_child(0)
	if level == 1:
		self.mesh = mesh_lvl2
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).mesh.top_radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).mesh.bottom_radius = (2*tower_range[level]+1)/1.2
		get_node("MobDetector").get_child(1).position.y = -1.6
		var mat = hat.get_surface_override_material(0)
		var mat_dup = mat.duplicate()
		mat_dup.albedo_texture = mage_lvl2
		hat.set_surface_override_material(0,mat_dup)
		var particle_mat = get_node("Mage").get_node("GPUParticles3D").draw_pass_1
		var particle_dup = particle_mat.duplicate(true)
		particle_dup.material.albedo_color = Color(0,1,0)
		get_node("Mage").get_node("GPUParticles3D").draw_pass_1 = particle_dup
	if level == 2:
		self.mesh = mesh_lvl3
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.top_radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.bottom_radius = (2*tower_range[level]+1)/1.2/1.2
		get_node("MobDetector").get_child(1).position.y = -1.38
		var mat = hat.get_surface_override_material(0)
		var mat_dup = mat.duplicate()
		mat_dup.albedo_texture = mage_lvl3
		hat.set_surface_override_material(0,mat_dup)
		var particle_mat = get_node("Mage").get_node("GPUParticles3D").draw_pass_1
		var particle_dup = particle_mat.duplicate(true)
		particle_dup.material.albedo_color = Color(1,0,0)
		get_node("Mage").get_node("GPUParticles3D").draw_pass_1 = particle_dup
	level += 1
	current_health = health[level-1]
	
func take_damage(dmg: int) -> void:
	print("im here")
	current_health-=dmg
	if current_health<=0 and (current_health+dmg) > 0:
		var col_point = self.position
		var grid_pos = grid_map.local_to_map(col_point)
		var tile_pos = Vector3(grid_pos.x+grid_map.map_size, grid_pos.y, grid_pos.z+grid_map.map_size)
		grid_map.tile_state[tile_pos.z][tile_pos.x] = 2
		queue_free()
