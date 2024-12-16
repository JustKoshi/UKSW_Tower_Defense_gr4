extends CharacterBody3D

var target 
var speed = 20
var arrow_damage

func _physics_process(_delta: float) -> void:
	if is_instance_valid(target):
		#making bullet follow the target with speed = to var set in the beginning of the script and facing it
		velocity=global_position.direction_to(target.global_position)*speed
		look_at(target.global_position)
		move_and_slide()
	else:
		queue_free()

#function that deals dmg when arrow finds enemy
func _on_collision_detector_body_entered(body: Node3D) -> void:
	if body.is_in_group("Enemies"):
		body.take_damage(arrow_damage)
		queue_free()
