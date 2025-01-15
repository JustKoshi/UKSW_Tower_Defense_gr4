extends CharacterBody3D

var title = "Fast Enemy"
var health=50
var damage = 3
var speed = 4.0/2
var description = "This enemy runs much\nfaster and deals\nmore dmg."
var finished_walk = false
var can_attack = true
var freezing = false
@onready var animation_player = $AnimationPlayer


func _physics_process(_delta):
	# Dodaj grawitacje do osi Y predkosci
	if finished_walk:
		play_attack_animation()
		if can_attack:
			can_attack=false
			$"Attack CD".start()
	else:
		play_run_animation()
	

func play_attack_animation():
	if animation_player.current_animation != "1H_Melee_Attack_Slice_Diagonal":
		animation_player.play("1H_Melee_Attack_Slice_Diagonal")

func play_run_animation():
	if animation_player.current_animation != "Running_A":
		animation_player.play("Running_A")
	
#func attack():
#	finished_walk = true

#Function that changes speed of the enemy when in range of freeze tower
func change_speed(value:float)->void:
	#print("Speed before change: ",get_parent_node_3d().speed)
	get_parent_node_3d().speed=get_parent_node_3d().speed * value
	#print("Speed after change: ",get_parent_node_3d().speed)#Testing purposes

#Function that happens when mob is struck with arrow/spell/canon
func take_damage(dmg: int) -> void:
	health-=dmg
	#print("Current health: ",health)
	if health<=0 and (health+dmg) > 0:
		get_parent_node_3d().delete_object()
		get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().update_enemy_killed_stats(title)

#Resetting attacking 
func _on_attack_cd_timeout() -> void:
	get_parent_node_3d().get_parent_node_3d().get_parent_node_3d().take_damage(damage)
	take_damage(50)
	can_attack=true
