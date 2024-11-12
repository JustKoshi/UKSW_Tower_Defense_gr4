extends Path3D

var curve_length = 0.0
var timer = 2
var fast_timer = 5

var spawnTime = 3 
var spawn_Fast_Time = 5

var enemy_limit = 100
var enemy_count = 0

var follower = preload("res://Scenes/enemy_path.tscn")
var fast_follower = preload("res://Scenes/fast_enemy_path.tscn")
var follower_list = []

func set_path(points: Array):
	#delete previous curve points
	curve.clear_points()
	
	#add new curve points
	for point in points:
		point.y -= 0.5
		curve.add_point(point)
	
	#length of path follower has to follow - important to understand 	
	curve_length = curve.get_baked_length()
	#
	#If we want to leave placing blocks during waves (otherwise remove):
	#updates the path length of every follower currently on the field
	if not follower_list.is_empty():
		for follower in follower_list:
			follower.set_curve_length(curve_length)

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	fast_timer += delta
	if timer > spawnTime and enemy_count < enemy_limit :
		timer = 0
		#We instantiate basic_enemy
		var new_follower = follower.instantiate()
		follower_list.append(new_follower)
		add_child(new_follower)
		new_follower.set_curve_length(curve_length)
		enemy_count+=1
	if fast_timer > spawn_Fast_Time and enemy_count < enemy_limit:
		fast_timer = 0
		
		var new_fast_follower = fast_follower.instantiate()
		follower_list.append(new_fast_follower)
		add_child(new_fast_follower)
		new_fast_follower.set_curve_length(curve_length)
		enemy_count+=1
