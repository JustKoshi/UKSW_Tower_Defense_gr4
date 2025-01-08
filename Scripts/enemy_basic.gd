extends CharacterBody3D

var health=100
var damage = 1
var finished_walk = false
var can_attack = true
var freezing = false
@onready var animation_player = $AnimationPlayer

func _physics_process(_delta):
	if finished_walk:
		play_attack_animation()
		if can_attack:
			can_attack=false
			$"Attack CD".start()
	else:
		play_run_animation()
		

func play_attack_animation():
	if animation_player.current_animation != "1H_Melee_Attack_Jump_Chop":
		animation_player.play("1H_Melee_Attack_Jump_Chop")


func play_run_animation():
	if animation_player.current_animation != "Running_A":
		animation_player.play("Running_A")
	
#Function that changes speed of the enemy when in range of freeze tower
func change_speed(value:float)->void:
	get_parent_node_3d().speed=get_parent_node_3d().speed * value

#Function that happens when mob is struck with arrow/spell/canon
func take_damage(dmg: int) -> void:
	health-=dmg
	if health<=0 and (health+dmg) > 0:
		get_parent_node_3d().delete_object()

#Resetting attacking 
func _on_attack_cd_timeout() -> void:
	take_damage(50)
	get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().take_damage(damage)
	can_attack=true
