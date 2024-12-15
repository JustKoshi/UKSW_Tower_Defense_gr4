extends MeshInstance3D

var slow = 0.75
var damage = 3
var health = 3
var range = 1
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

func _process(_delta: float) -> void:
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


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			#print("Freeze Tower clicked!")
			emit_signal("tower_info",self)

func round_to_decimals(value: float, decimals: int) -> float:
	var factor = pow(10, decimals)
	return round(value * factor) / factor
