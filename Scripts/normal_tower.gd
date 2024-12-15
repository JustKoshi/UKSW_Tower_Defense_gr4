extends MeshInstance3D

var bullet = preload("res://Scenes/bullet.tscn")
var damage = 30
var health = 5
var range = 2
var level = 1
var firerate
var title = "Normal Tower"
var enemies = []
var current_enemy
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
	return_wood = 4
	return_stone = 4
	wood_to_upgrade_lvl2 = 10
	stone_to_upgrade_lvl2 = 10
	wheat_to_upgrade_lvl2 = 10
	wood_to_upgrade_lvl3 = 50
	stone_to_upgrade_lvl3 = 50
	wheat_to_upgrade_lvl3 = 50
	firerate = 1/get_node("Shooting CD").wait_time

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
	new_bullet.target=current_enemy.get_node("Aim")
	new_bullet.arrow_damage=damage
	get_node("Bullets").add_child(new_bullet)
	new_bullet.global_position = $Aim2.global_position

#Resetting can_shoot after CD passed
func _on_shooting_cd_timeout() -> void:
	can_shoot=true


func _process(_delta: float) -> void:
	set_target(enemies)
	if is_instance_valid(current_enemy):
		if can_shoot:
			shooting()
			can_shoot=false
			$"Shooting CD".start()


func _on_static_body_3d_input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			#print("Normal Tower clicked!")
			emit_signal("tower_info",self)
			
