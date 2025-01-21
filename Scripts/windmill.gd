class_name Windmill
extends MeshInstance3D
@onready var game_script = get_parent().get_parent()

@onready var standard_mesh = "res://Resources/Resource_buildings/lumbermill_v2.obj"
@onready var disabled_mesh = "res://building_destroyed.obj"

var generator_on = true
var resource_type = "wheat"

var generation_depleted = true

var title = "Windmill"
var shape = [Vector3(0,0,0), Vector3(1,0,0), Vector3(0,0,1)]
var sprite_phase = false
var sprite
#not generating and non-destroyable
var disabled = false

#round counter after the resource gets disabled
var round

signal resource_info(obj)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	sprite = get_node("Sprite3D")
	sprite.visible = false

func _process(_delta: float) -> void:
	if sprite_phase:
		sprite.visible = true
		var camera = get_viewport().get_camera_3d()
		if camera:
			sprite.look_at(camera.global_transform.origin, Vector3.UP)
	if disabled:
		if round == game_script.enemy_spawner.current_wave:
			disabled = false



func _on_timer_timeout() -> void:
	generator_on = true

func _on_static_body_3d_input_event(_camera: Node, event: InputEvent, _event_position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:  # Left mouse button
			#print("Normal Tower clicked!")
			emit_signal("resource_info",self)

#collision with sprite
func _input_event(camera: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			print("Sprite clicked!")
			sprite_phase = false
			sprite.visible = false
			game_script.stats.minigames_won += 1
			if game_script.enemy_spawner.current_wave<=10:
				game_script.game_resources[resource_type]+=10

func _on_sprite_countdown_timeout() -> void:
	if sprite_phase:
		if game_script.enemy_spawner.current_wave>=5:
			disabled = true
		sprite_phase = false
		sprite.visible = false
	round = game_script.enemy_spawner.current_wave
	round+=2
	
