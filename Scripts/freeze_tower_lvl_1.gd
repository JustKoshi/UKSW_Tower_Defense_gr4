extends MeshInstance3D

var slow = 0.75
var damage = 3
var health = 3
var tower_range= 1
var level = 1
var firerate
var title = "Freeze Tower"
var enemies = []
var can_shoot = true

var return_wood
var return_stone
var wood_to_upgrade_lvl2
var stone_to_upgrade_lvl2
var wheat_to_upgrade_lvl2
var wood_to_upgrade_lvl3
var stone_to_upgrade_lvl3
var wheat_to_upgrade_lvl3

signal tower_info(object)

var mesh_lvl2 = load("res://Resources/Towers/FreezeTowerlvl1/building_tower_A_green.obj")
var mesh_lvl3 = load("res://Resources/Towers/FreezeTowerlvl1/building_tower_A_red.obj")
var mage_lvl2 = load("res://Resources/Icons/green_heart.png")
var mage_lvl3 = load("res://Resources/Icons/Heart.png")

func _ready() -> void:
	return_wood = 6
	return_stone = 6
	wood_to_upgrade_lvl2 = 15
	stone_to_upgrade_lvl2 = 15
	wheat_to_upgrade_lvl2 = 15
	wood_to_upgrade_lvl3 = 75
	stone_to_upgrade_lvl3 = 75
	wheat_to_upgrade_lvl3 = 75
	firerate = round_to_decimals(1/get_node("Damage CD").wait_time,2)
	get_node("MobDetector").get_child(0).shape.radius = 2*tower_range+1
	get_node("MobDetector").get_child(1).mesh.radius = 2*tower_range+1
	get_node("MobDetector").get_child(1).mesh.height = 2 * get_node("MobDetector").get_child(1).mesh.radius

func _process(_delta: float) -> void:
	for i in enemies:
		if i.freezing == false:
			i.freezing = true
			i.change_speed(slow)
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
				body.change_speed(slow)
				

func _on_mob_detector_body_exited(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		enemies.erase(body)
		if body.freezing == true:
			body.freezing = false
			body.change_speed(1/slow)

func deal_dmg():
	for e in enemies:
		e.take_damage(damage)
	
	
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
		health = 4
		slow = 0.65
		self.mesh = mesh_lvl2
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range+1)/1.2
		get_node("MobDetector").get_child(1).mesh.radius = (2*tower_range+1)/1.2
		get_node("MobDetector").get_child(1).mesh.height = 2 * get_node("MobDetector").get_child(1).mesh.radius
		var mat = hat.get_surface_override_material(0)
		var mat_dup = mat.duplicate()
		mat_dup.albedo_texture = mage_lvl2
		hat.set_surface_override_material(0,mat_dup)
		var particle_mat = get_node("Mage").get_node("GPUParticles3D").draw_pass_1
		var particle_dup = particle_mat.duplicate(true)
		particle_dup.material.albedo_color = Color(0,1,0)
		get_node("Mage").get_node("GPUParticles3D").draw_pass_1 = particle_dup
	if level == 2:
		health = 5
		slow = 0.5
		damage = 5
		self.mesh = mesh_lvl3
		self.scale_object_local(Vector3(1.2,1.2,1.2))
		get_node("MobDetector").get_child(0).shape.radius = (2*tower_range+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.radius = (2*tower_range+1)/1.2/1.2
		get_node("MobDetector").get_child(1).mesh.height = 2 * get_node("MobDetector").get_child(1).mesh.radius
		var mat = hat.get_surface_override_material(0)
		var mat_dup = mat.duplicate()
		mat_dup.albedo_texture = mage_lvl3
		hat.set_surface_override_material(0,mat_dup)
		var particle_mat = get_node("Mage").get_node("GPUParticles3D").draw_pass_1
		var particle_dup = particle_mat.duplicate(true)
		particle_dup.material.albedo_color = Color(1,0,0)
		get_node("Mage").get_node("GPUParticles3D").draw_pass_1 = particle_dup
	level += 1
	
