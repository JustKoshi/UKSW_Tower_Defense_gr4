extends PathFollow3D

var speed = 1 #how fast character will follow path
var curve_length = 0.0
@onready var enemy = $Skeleton_Minion
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_curve_length(length) -> void:
	curve_length = length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += speed * delta  # Poruszanie wzdluz sciezki

	if progress >= curve_length and is_instance_valid(enemy):
		if enemy.finished_walk==false:
			enemy.finished_walk=true
		  # Resetuj offset, gdy osiagnie koniec

func delete_object()->void:
	get_parent_node_3d().delete_enemy()
	queue_free()

