extends Node3D
@onready var anim = $AnimationPlayer
var particles:bool = true


func _process(delta: float) -> void:
	if !get_parent_node_3d().enemies.is_empty():
		if particles:
			$GPUParticles3D.emitting = true
			$GPUParticles3D/Timer.start()
			particles = false
		if anim.current_animation != "2H_Melee_Attack_Spin":
			anim.play("2H_Melee_Attack_Spin")
	else:
		anim.stop()
		$GPUParticles3D.emitting = false


func _on_timer_timeout() -> void:
	particles = true
