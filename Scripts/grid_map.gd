extends GridMap



#all tetris block shapes and their rotations
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

#all directions to chceck for dfs and bfs search
const DIRECTIONS = [Vector3(0, 0, 1), Vector3(0, 0, -1), Vector3(1, 0, 0), Vector3(-1, 0, 0)]

var index = 0 #Rotation of the block index
var block_index = 0 #index of block in all_tetris_blocks
#array that holds all tetris block arrays
var all_tetris_blocks = [tetris_blocks_L, tetris_blocks_sqr, tetris_blocks_J, tetris_blocks_Z, tetris_blocks_I, tetris_blocks_T, tetris_blocks_S]
var current_block = all_tetris_blocks[block_index] #current tetris block
var current_shape = current_block[index] #current exact block shape (rotation)
var tile_state = [] #We will call this array tileset. It holds current state of map but in 2D. 0-nothing 1-temp block 2-tetris block 3-tetris block with tower on

var shortest_path = [] #Array that will hold fastest route from start to finish

var block_color = [1,3,5,7,8] #array that holds index of tetris blocks in mesh
var block_type = block_color[0] #current block color


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_used_tiles()
	randomize_block()
	for i in range(10):
		tile_state.append([0, 0, 0, 0, 0, 0, 0, 0, 0, 0])
	generate_start_end_points()
	shortest_path = find_shortest_path(start_point, end_point)
	convert_path_to_grid_map()
	mark_shortest_path()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
func rotate_block_forward():
	index += 1
	current_shape = current_block[index%4]

func rotate_block_backwards():
	if index == 0:
		index = 3
	else:
		index -= 1
		
	current_shape = current_block[index%4]

#randomize tetris block
func randomize_block():
	
	block_index = randi() % all_tetris_blocks.size()
	current_block = all_tetris_blocks[block_index]
	current_shape = current_block[index%4]
	index = 0
	
func randomize_color():
	block_type = block_color[randi() % block_color.size()]
	
#Checks if block is within bounds of map
func is_within_bounds(pos_vector: Vector3) -> bool:
	return pos_vector.x>=(-map_size) and pos_vector.x<map_size and pos_vector.z>=(-map_size) and pos_vector.z<map_size and pos_vector.y == 1

#checks if block is within tileset bounds
func is_within_tile_bounds(pos_vector: Vector3) -> bool:
	return pos_vector.x>=0 and pos_vector.x<map_size*2 and pos_vector.z>=0 and pos_vector.z<map_size*2 and pos_vector.y == 1

#Checks in single block can be placed.
func can_place_block(pos_vector: Vector3) -> bool:
	#checks if block is within bounds
	if not is_within_bounds(pos_vector):
		print("Place is out of bounds")
		return false
		
	#checks if there is already block in pos_vector place 
	if self.get_cell_item(pos_vector)!=-1:
		print("Place is taken")
		return false
	
	#Checks if start/finish path exist upon placing block
	if not does_path_exist(start_point, end_point):
		print("Path not found")
		return false
		
	return true

#places temporary block in tilemap for further analysis
func place_block_in_tilemap_temp(position: Vector3):
	if is_within_bounds(position):
		var tile_pos = Vector3(position.x+map_size, position.y, position.z+map_size)
		if(tile_state[tile_pos.z][tile_pos.x] == 0):
			tile_state[tile_pos.z][tile_pos.x] = 1

#replaces temporary block in tilemap with pernament one		
func place_block_in_tilemap_permanent(position: Vector3):
	if is_within_bounds(position):
		var tile_pos = Vector3(position.x+map_size, position.y, position.z+map_size)
		if(tile_state[tile_pos.z][tile_pos.x]==1):
			tile_state[tile_pos.z][tile_pos.x] = 2

#removes invalid block from tilemap	
func remove_block_from_tilemap(position: Vector3):
	if is_within_bounds(position):
		var tile_pos = Vector3(position.x+map_size, position.y, position.z+map_size)
		if(tile_state[tile_pos.z][tile_pos.x]==1):
			tile_state[tile_pos.z][tile_pos.x] = 0

#places single block in grid, block_type = number in mesh_lib array (mesh_lib.tres)	
func place_block(position_vec: Vector3):
	
	if can_place_block(position_vec):
		set_cell_item(position_vec,block_type)
		print("Bloczek postawiony na pozycji: ", position_vec)

#function checks if tetris block can be placed in desirable spot
#Places temporary block in tilemap and checks if position is valid
func can_place_tetris_block(grid_pos: Vector3, shape):
	var flag = true
	for pos in shape:
		var new_pos = grid_pos + pos
		place_block_in_tilemap_temp(new_pos)
		if not (can_place_block(new_pos)):
			print("Can't place Tetris block here")
			flag = false
			break
			
	if not flag:
		for pos in shape:
			var new_pos = grid_pos + pos
			remove_block_from_tilemap(new_pos)
	
	return flag
	
#Checks if there is any path from start to end point using dfs search	
func does_path_exist(start: Vector3, end: Vector3) -> bool:
	var start_pos = Vector3(start.x+map_size, start.y, start.z+map_size)
	var end_pos = Vector3(end.x+map_size, end.y, end.z+map_size)
	
	if tile_state[start_pos.z][start_pos.x] == 1 or tile_state[end_pos.z][end_pos.x] == 1:
		print("Start/end point cannot be blocked")
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
	if tile_state[current_pos.z][current_pos.x] == 1 or visited[current_pos.z][current_pos.x] or tile_state[current_pos.z][current_pos.x] == 2 or tile_state[current_pos.z][current_pos.x] == 3:
		return false
	
	visited[current_pos.z][current_pos.x] = true
	
	for direction in DIRECTIONS:
		var new_pos = current_pos + direction
		if dfs_search(new_pos, target_pos, visited):
			return true
				
	return false
	
#places whole tetris block checking all nessessary conditions	
func place_tetris_block(position_tetris: Vector3, shape):
	if can_place_tetris_block(position_tetris, shape):
		for block in shape:
			place_block(block+position_tetris)
			place_block_in_tilemap_permanent(block+position_tetris)
		randomize_block()
		randomize_color()
		shortest_path = find_shortest_path(start_point, end_point)
		convert_path_to_grid_map()
		mark_shortest_path()
		#print(shortest_path)
		#for row in tile_state:
			#print(row)
		
#generates start/end points and places them in map
func generate_start_end_points():
	end_point = Vector3((-map_size)-1 ,0, randi()%10 - map_size)
	start_point = Vector3(map_size,0, randi()%10 - map_size)
	self.set_cell_item(start_point, 4)
	self.set_cell_item(end_point, 4)
	start_point = Vector3(start_point.x-1,start_point.y+1, start_point.z)
	end_point = Vector3(end_point.x+1,end_point.y+1, end_point.z)
	print("Start_point" + str(start_point))
	print("end_point" + str(end_point))
	

#func print_used_tiles():
	#for x in range(-5, 5):
		#for z in range(-5, 5):
			#var cell_position = Vector3(x,0,z)
			#var item_id = get_cell_item(cell_position)
			#if item_id != -1:
				#print("Kafelek użyty na pozycji:", cell_position, " - ID kafelka:", item_id)
				
func reconstruct_path(parent: Dictionary, start: Vector3, end: Vector3) -> Array:
	var path = []
	var current = end
	
	while current != start:
		path.append(current)
		current = parent[current]
	
	path.append(start)
	path.reverse()      # We reverse the path to have it in right direction
	return path
	
func find_shortest_path(start: Vector3, end: Vector3) -> Array:
	var start_pos = Vector3(start.x+map_size, start.y, start.z+map_size)
	var end_pos = Vector3(end.x+map_size, end.y, end.z+map_size)
	#check if start/end pos is within tile bounds
	if not is_within_tile_bounds(start_pos) or not is_within_tile_bounds(end_pos):
		print("Start or end out of bounds")
		return []
	
	var queue = []  # We use array as queue
	var visited = []  # Follows visited nodes
	var parent = {}   # Follows previous position
	queue.append(start_pos)
	visited.append(start_pos)
	while queue.size()>0:
		var current = queue.pop_front()

		# check if we reach end point
		if current == end_pos:
			return reconstruct_path(parent, start_pos, end_pos)

		# Checks all neighbors of point
		for direction in DIRECTIONS:
			var neighbor = current + direction
			
			# Checks if neighbor is within tileset bounds, if neighbor is a blockade and if was visited before
			if is_within_tile_bounds(neighbor) and tile_state[neighbor.z][neighbor.x] < 2 and not visited.has(neighbor):
				visited.append(neighbor)
				parent[neighbor] = current  # Ustawienie rodzica
				queue.append(neighbor)
	return []

#Converts shorest_path array to grid equivalents
func convert_path_to_grid_map():
	for i in range(shortest_path.size()):
		shortest_path[i] = Vector3(shortest_path[i].x-map_size, shortest_path[i].y-1, shortest_path[i].z - map_size)

#Uses shortest_path_array to mark in on map
func mark_shortest_path():
	for pos in shortest_path:
		self.set_cell_item(pos, 6)
	for i in range(-5,5):
		for j in range(-5, 5):
			var grid_pos = Vector3(i ,0 ,j)
			if grid_pos not in shortest_path:
				self.set_cell_item(grid_pos, 0)
				
#function checking if tower can be placed on top of tetris block
func can_place_tower(col_point: Vector3)->bool:
	var grid_pos = self.local_to_map(col_point)
	grid_pos.y=1
	if is_within_bounds(grid_pos):
		var tile_pos = Vector3(grid_pos.x+map_size, grid_pos.y, grid_pos.z+map_size)
		if tile_state[tile_pos.z][tile_pos.x]==2:
			return true
		else:
			return false
	else:
		return false

#fucntion that updates tilemap after placing tower
func place_tower_in_tilemap(col_point: Vector3)->void:
	var grid_pos = self.local_to_map(col_point)
	var tile_pos = Vector3(grid_pos.x+map_size, grid_pos.y, grid_pos.z+map_size)
	if tile_state[tile_pos.z][tile_pos.x]==2:
		tile_state[tile_pos.z][tile_pos.x]=3
