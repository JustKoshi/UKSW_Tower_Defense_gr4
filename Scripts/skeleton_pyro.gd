extends CharacterBody3D

var health=300
var damage = 1
var finished_walk = false
var can_attack = true
var freezing = false
var targeting_tower = false
var title = "Pyro"
var speed = 4.0/2
var description = "Enemy targeting\ntowers and resource\nbuildings"
@onready var animation_player = $AnimationPlayer

var target:StaticBody3D = null



func _physics_process(_delta):
	if target != null and not finished_walk:
		if calculate_distance(self.global_position, target.global_position) <= 2.85:
			
			finished_walk = true
			self.get_parent_node_3d().speed = 0
			self.look_at(target.global_position)
			rotate_y(deg_to_rad(180))
			
	if finished_walk:
		play_attack_animation()
		if can_attack:
			can_attack=false
			$"Attack CD".start()
	else:
		play_run_animation()
		

func play_attack_animation():
	if animation_player.current_animation != "Unarmed_Melee_Attack_Punch_A":
		animation_player.play("Unarmed_Melee_Attack_Punch_A")


func play_run_animation():
	if animation_player.current_animation != "Running_C":
		animation_player.play("Running_C")
	
#Function that changes speed of the enemy when in range of freeze tower
func change_speed(value:float)->void:
	get_parent_node_3d().speed=get_parent_node_3d().speed * value

#Function that happens when mob is struck with arrow/spell/canon
func take_damage(dmg: int) -> void:
	health-=dmg
	if (health<=0) and (health+dmg) > 0:
		get_parent_node_3d().delete_object()

#Resetting attacking 
func _on_attack_cd_timeout() -> void:
	
	if not targeting_tower:
		get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().take_damage(damage)
		get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().destoy_resource_building()
		take_damage(300)
		
	else:
		target.get_parent_node_3d().take_damage(damage)
		take_damage(150)
	can_attack=true


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("towers") and target==null:
		print("tower detected")
		target = body
		targeting_tower = true
		print(str(body.global_position))
	

func calculate_distance(vec1: Vector3, vec2: Vector3)->float:
	return vec1.distance_to(vec2)

	


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("towers") and target != null:
		print("invalid target removed")
		target = null
