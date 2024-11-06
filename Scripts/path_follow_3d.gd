extends PathFollow3D

var speed = 1 #how fast character will follow path
var curve_length = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_curve_length(length) -> void:
	curve_length = length

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	progress += speed * delta  # Poruszanie wzdłuż ścieżki
	if progress >= curve_length:
		progress = 0.0  # Resetuj offset, gdy osiągnie koniec
