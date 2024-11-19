extends Node3D
@onready var anim = $AnimationPlayer

func _process(delta: float) -> void:
	if !get_parent_node_3d().enemies.is_empty():
		if anim.current_animation != "2H_Melee_Attack_Spin":
			anim.play("2H_Melee_Attack_Spin")
