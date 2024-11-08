extends CharacterBody3D

var is_attacking = false
@onready var animation_player = $AnimationPlayer

func _physics_process(delta):
	# Dodaj grawitację do osi Y prędkości
	if is_attacking:
		play_attack_animation()
		is_attacking = false
	else:
		play_run_animation()
		
	

func play_attack_animation():
	if animation_player.current_animation != "1H_Melee_Attack_Stab":
		animation_player.play("1H_Melee_Attack_Stab")

func play_run_animation():
	if animation_player.current_animation != "Running_A":
		animation_player.play("Running_A")
	
func attack():
	is_attacking = true
