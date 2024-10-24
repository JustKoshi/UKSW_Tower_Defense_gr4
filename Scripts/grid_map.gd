extends GridMap

var block_type = 1

var tetris_blocks_L = [
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(0,0,-1), Vector3(0,0,-2)],
	[Vector3(0,0,-1), Vector3(1,0,-1), Vector3(0,0,0), Vector3(2,0,-1)], 
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(1,0,1), Vector3(1,0,2)], 
	[Vector3(0,0,0), Vector3(0,0,1), Vector3(-1,0,1), Vector3(-2,0,1)]
]
var tetris_blocks_sqr = [
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(-1,0,-1), Vector3(-1,0,0)],
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(-1,0,-1), Vector3(-1,0,0)],
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(-1,0,-1), Vector3(-1,0,0)],
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(-1,0,-1), Vector3(-1,0,0)]
]
var tetris_blocks_J = [
	[Vector3(0,0,0), Vector3(-1,0,0), Vector3(1,0,0), Vector3(1,0,-1)],  # First rotation
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,1), Vector3(1,0,1)],   # Second rotation
	[Vector3(0,0,0), Vector3(-1,0,0), Vector3(1,0,0), Vector3(-1,0,1)],  # Third rotation
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,1), Vector3(-1,0,-1)]  # Forth rotation
]
var tetris_blocks_Z = [
	[Vector3(0,0,0), Vector3(-1,0,0), Vector3(0,0,-1), Vector3(1,0,-1)],  # Pierwsza rotacja
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(-1,0,-1), Vector3(-1,0,-2)], # Druga rotacja
	[Vector3(0,0,0), Vector3(-1,0,0), Vector3(0,0,-1), Vector3(1,0,-1)],  # Trzecia rotacja (taka sama jak pierwsza)
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(-1,0,-1), Vector3(-1,0,-2)]  # Czwarta rotacja (taka sama jak druga)
]
var tetris_blocks_I = [
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(2,0,0), Vector3(3,0,0)],    # Pierwsza rotacja (pozioma)
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,-2), Vector3(0,0,-3)], # Druga rotacja (pionowa)
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(2,0,0), Vector3(3,0,0)],    # Trzecia rotacja (pozioma)
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,-2), Vector3(0,0,-3)]  # Czwarta rotacja (pionowa)
]
var tetris_blocks_T = [
	[Vector3(0,0,0), Vector3(-1,0,0), Vector3(1,0,0), Vector3(0,0,-1)],  # Pierwsza rotacja
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,1), Vector3(1,0,0)],   # Druga rotacja
	[Vector3(0,0,0), Vector3(-1,0,0), Vector3(1,0,0), Vector3(0,0,1)],   # Trzecia rotacja
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(0,0,1), Vector3(-1,0,0)]   # Czwarta rotacja
]
var tetris_blocks_S = [
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(0,0,-1), Vector3(-1,0,-1)], # Pierwsza rotacja
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(1,0,-1), Vector3(1,0,-2)], # Druga rotacja
	[Vector3(0,0,0), Vector3(1,0,0), Vector3(0,0,-1), Vector3(-1,0,-1)], # Trzecia rotacja (taka sama jak pierwsza)
	[Vector3(0,0,0), Vector3(0,0,-1), Vector3(1,0,-1), Vector3(1,0,-2)]  # Czwarta rotacja (taka sama jak druga)
]

var start_point = Vector3(5,0,0)
var end_point = Vector3(-6,0,0)

#map size is 10x10 but q1-q4 are size 5x5 so it is simpler to use 5 couse map coordinates -5,4
var map_size = 5

var index = 0
var block_index = 0
var all_tetris_blocks = [tetris_blocks_L, tetris_blocks_sqr, tetris_blocks_J, tetris_blocks_Z, tetris_blocks_I, tetris_blocks_T, tetris_blocks_S]
var current_block = all_tetris_blocks[block_index]
var current_shape = current_block[index]
var tile_state = [] #Array that will hold current state of grid_map 0 empty 1 taken

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_used_tiles()
	randomize_block()
	for i in range(10):
		tile_state.append([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	generate_start_end_points()
	
func rotate_block_forward():
	index += 1
	current_shape = current_block[index%4]

func rotate_block_backwards():
	if index == 0:
		index = 3
	else:
		index -= 1
		
	current_shape = current_block[index%4]

func randomize_block():
	
	block_index = randi() % all_tetris_blocks.size()
	current_block = all_tetris_blocks[block_index]
	current_shape = current_block[index%4]
	index = 0
	
#Checks if block is within bounds of map
func is_within_bounds(pos_vector: Vector3) -> bool:
	return pos_vector.x>=(-map_size) and pos_vector.x<map_size and pos_vector.z>=(-map_size) and pos_vector.z<map_size and pos_vector.y == 1

func is_within_tile_bounds(pos_vector: Vector3) -> bool:
	return pos_vector.x>=0 and pos_vector.x<map_size*2 and pos_vector.z>=0 and pos_vector.z<map_size*2 and pos_vector.y == 1

func can_place_block(pos_vector: Vector3) -> bool:
	if not is_within_bounds(pos_vector):
		print("Place is out of bounds")
		return false
	if self.get_cell_item(pos_vector)!=-1:
		print("Place is taken")
		return false
	
	if not does_path_exist(start_point, end_point):
		print("Path not found")
		return false
		
	return true

func place_block_in_tilemap(position: Vector3):
	if is_within_bounds(position):
		var tile_pos = Vector3(position.x+map_size, position.y, position.z+map_size)
		tile_state[tile_pos.z][tile_pos.x] = 1
	
func remove_block_from_tilemap(position: Vector3):
	if is_within_bounds(position):
		var tile_pos = Vector3(position.x+map_size, position.y, position.z+map_size)
		tile_state[tile_pos.z][tile_pos.x] = 0
	
func place_block(position_vec: Vector3):
	
	if can_place_block(position_vec):
		self.set_cell_item(position_vec,block_type)
		print("Bloczek postawiony na pozycji: ", position_vec)

func can_place_tetris_block(grid_pos: Vector3, shape):
	var flag = true
	for pos in shape:
		var new_pos = grid_pos + pos
		place_block_in_tilemap(new_pos)
		if not (can_place_block(new_pos)):
			print("Can't place Tetris block here")
			flag = false
			break
			
	if not flag:
		for pos in shape:
			var new_pos = grid_pos + pos
			remove_block_from_tilemap(new_pos)
	
	return flag
	
func does_path_exist(start: Vector3, end: Vector3) -> bool:
	var start_pos = Vector3(start.x+map_size, start.y, start.z+map_size)
	var end_pos = Vector3(end.x+map_size, end.y, end.z+map_size)
	
	if tile_state[start_pos.z][start_pos.x] == 1 or tile_state[end_pos.z][end_pos.x] == 1:
		print("Start/end point blocked")
		return false

	var visited = []
	for i in range(map_size*2):
		visited.append([false, false, false, false, false, false, false, false, false, false])
	
	return dfs_search(start_pos, end_pos, visited)
	
func dfs_search(current_pos: Vector3,target_pos: Vector3, visited) -> bool:
	
	if current_pos == target_pos:
		return true
	if not is_within_tile_bounds(current_pos):
		return false
	if tile_state[current_pos.z][current_pos.x] == 1 or visited[current_pos.z][current_pos.x]:
		return false
	
	visited[current_pos.z][current_pos.x] = true
	
	var directions = [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]
	
	for direction in directions:
		var new_pos = current_pos + direction
		if dfs_search(new_pos, target_pos, visited):
			return true
				
	return false
	
func place_tetris_block(position_tetris: Vector3, shape):
	if can_place_tetris_block(position_tetris, shape):
		for block in shape:
			place_block(block+position_tetris)
		randomize_block()
		
	#for row in tile_state:
		#print(row)
		
func generate_start_end_points():
	end_point = Vector3((-map_size)-1 ,0, randi()%10 - map_size)
	start_point = Vector3(map_size,0, randi()%10 - map_size)
	self.set_cell_item(start_point, 3)
	self.set_cell_item(end_point, 3)
	start_point = Vector3(start_point.x-1,start_point.y+1, start_point.z)
	end_point = Vector3(end_point.x+1,end_point.y+1, end_point.z)
	print("Start_point" + str(start_point))
	print("end_point" + str(end_point))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

#func print_used_tiles():
	#for x in range(-5, 5):
		#for z in range(-5, 5):
			#var cell_position = Vector3(x,0,z)
			#var item_id = get_cell_item(cell_position)
			#if item_id != -1:
				#print("Kafelek użyty na pozycji:", cell_position, " - ID kafelka:", item_id)
