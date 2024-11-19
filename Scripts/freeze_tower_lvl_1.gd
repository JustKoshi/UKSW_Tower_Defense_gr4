extends MeshInstance3D

var slow = 0.75
var damage = 3
var enemies = []
var can_dmg = true


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
	
func _process(delta: float) -> void:
	if !enemies.is_empty():
		if can_dmg:
			deal_dmg()
			can_dmg=false
			$"Damage CD".start()
	
#Resetting can_dmg after CD passed
func _on_damage_cd_timeout() -> void:
	can_dmg=true
