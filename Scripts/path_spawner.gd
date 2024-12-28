extends Path3D

var curve_length = 0.0

var timer = 0.0
var fast_timer = 0.0
var boss_timer = 0.0

var basic_enemy_spawn_cd = 2.0

var fast_enemy_initial_delay = 20.0
var fast_enemy_spawn_cd = 3.0

var boss_enemy_initial_delay = 5.0
var boss_enemy_spawn_cd = 5.0


var current_wave = 1
var basic_enemies_per_wave = 4
var fast_enemies_per_wave = 0
var boss_enemies_per_wave = 0
var basic_enemy_increment = 2

var enemy_count = 0 #current alive enemies count
var fast_enemy_count = 0 # how many fast enemies spawned
var basic_enemy_count = 0
var boss_enemy_count = 0
var spawned_enemy_count = 0

var follower = preload("res://Scenes/enemy_path.tscn")
var fast_follower = preload("res://Scenes/fast_enemy_path.tscn")
var boss_follower = preload("res://Scenes/boss_path.tscn")

var wave_in_progress = false
var fast_enemy_spawn_started = false
var boss_enemy_spawn_started = false

signal wave_ended(wave_number)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print("EC ",enemy_count,"     SEC ",spawned_enemy_count,"      Basic ",basic_enemies_per_wave,"       fast ",fast_enemies_per_wave)
	if wave_in_progress:
		timer += delta
	#spawn basic enemy:
	if timer > basic_enemy_spawn_cd  and basic_enemy_count < basic_enemies_per_wave and wave_in_progress:
		timer = 0
		basic_enemy_count+=1
		spawn_enemy(follower)
		randomize_basic_enemy_cd()
		
	# delay before spawning first fast enemy for it to not die in 1 second
	if not fast_enemy_spawn_started and wave_in_progress:
		
		if fast_timer >= fast_enemy_initial_delay:
			fast_timer = 0
			fast_enemy_spawn_started = true
			print("Fast enemy spawn started!")
	
	if fast_enemies_per_wave > 0:
		fast_timer+=delta
	
	#spawn fast fast enemy and randomize it's spawn cd if fast enemy can be spawned
	if fast_enemy_spawn_started and fast_timer > fast_enemy_spawn_cd and fast_enemy_count < fast_enemies_per_wave and wave_in_progress:
		fast_enemy_count += 1
		fast_timer = 0
		spawn_enemy(fast_follower)
		randomize_fast_enemy_cd()
	
	if not boss_enemy_spawn_started and wave_in_progress:
		
		if boss_timer >= boss_enemy_initial_delay:
			boss_timer = 0
			boss_enemy_spawn_started = true
			print("Boss enemy spawn started!")
	
	if boss_enemies_per_wave > 0:
		boss_timer+=delta
	
	if boss_enemy_spawn_started and boss_timer > boss_enemy_spawn_cd and boss_enemy_count < boss_enemies_per_wave and wave_in_progress:
		boss_enemy_count += 1
		boss_timer = 0
		spawn_enemy(boss_follower)
		
	
	#ends wave when spawned enemy count is equal to total enemy count tbc
	if spawned_enemy_count >= basic_enemies_per_wave + fast_enemies_per_wave and enemy_count == 0 and wave_in_progress:
		end_wave()
	
func set_path(points: Array) -> void:
	#delete previous curve points
	curve.clear_points()

	#add new curve points
	for point in points:
		point.y -= 0.5
		curve.add_point(point)

	#length of path follower has to follow - important to understand 	
	curve_length = curve.get_baked_length()

func delete_enemy()->void:
	enemy_count -= 1

#spawns enemy of type enemy_scene and adds it overall enemy count
func spawn_enemy(enemy_scene):
	if spawned_enemy_count >= basic_enemies_per_wave + fast_enemies_per_wave:
		return
	var new_enemy = enemy_scene.instantiate()
	add_child(new_enemy)
	new_enemy.set_curve_length(curve_length)
	enemy_count += 1
	spawned_enemy_count += 1

#starts wave and resets all variables	
func start_wave():
	print("Fala: " + str(current_wave))
	
	wave_in_progress = true
	enemy_count = 0
	spawned_enemy_count = 0
	
	fast_timer = 0
	fast_enemy_spawn_started = false
	fast_enemy_spawn_cd = 3.0
	fast_enemy_count = 0
	
	boss_timer = 0
	boss_enemy_spawn_started = false
	boss_enemy_count = 0
	
	basic_enemy_count = 0
	
#ends wave and emits signal to main scene	
func end_wave():
	print("Fala " + str(current_wave) + " zakonczona!")
	wave_in_progress = false
	emit_signal("wave_ended")
	
#here updates each of enemy count based on current wave
func update_wave_enemy_count():
	basic_enemies_per_wave = 4 + (current_wave-1)*basic_enemy_increment
	print("basic przeciwnicy: " + str(basic_enemies_per_wave))
	fast_enemies_per_wave = int((current_wave/ 3))
	print("Fast przeciwnicy: " + str(fast_enemies_per_wave))
	boss_enemies_per_wave = int((current_wave/10))
	print("Boss przeciwnicy: " + str(boss_enemies_per_wave))

func randomize_fast_enemy_cd():
	fast_enemy_spawn_cd = randf_range(3.0, 6.0)

func randomize_basic_enemy_cd():
	basic_enemy_spawn_cd = randf_range(1.5, 2.5)
