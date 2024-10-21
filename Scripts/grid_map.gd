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

var index = 0
var block_index = 0
var all_tetris_blocks = [tetris_blocks_L, tetris_blocks_sqr, tetris_blocks_J, tetris_blocks_Z, tetris_blocks_I, tetris_blocks_T, tetris_blocks_S]
var current_block = all_tetris_blocks[block_index]
var current_shape = current_block[index]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_used_tiles()
	randomize_block()
	
func rotate_block_forward():
	index += 1
	current_shape = current_block[index%4]

func rotate_block_backwards():
	if index > 0:
		index -= 1
		current_shape = current_block[index%4]

func randomize_block():
	block_index = randi() % all_tetris_blocks.size()
	current_block = all_tetris_blocks[block_index]
	current_shape = current_block[index%4]
	index = 0
func place_block(position_vec: Vector3):
	if can_place_block(position_vec):
		self.set_cell_item(position_vec,block_type)
		print("Bloczek postawiony na pozycji: ", position_vec)
	
func place_tetris_block(position_tetris: Vector3, shape):
	if can_place_tetris_block(position_tetris, shape):
		for block in shape:
			place_block(block+position_tetris)
		print(block_index)
		randomize_block()

#Checks if block is within bounds of map
func is_within_bounds(pos_vector: Vector3) -> bool:
	return pos_vector.x>=-5 and pos_vector.x<5 and pos_vector.z>=-5 and pos_vector.z<5 and pos_vector.y == 1

func can_place_block(pos_vector: Vector3) -> bool:
	if not is_within_bounds(pos_vector):
		print("Place is out of bounds")
		return false
	if self.get_cell_item(pos_vector)!=-1:
		print("Place is taken")
		return false
	return true


func can_place_tetris_block(grid_pos: Vector3, shape):
	for pos in shape:
		var new_pos = grid_pos + pos
		if not (can_place_block(new_pos)):
			print("Can't place block here")
			return false
	return true
	
#func print_used_tiles():
	#for x in range(-5, 5):
		#for z in range(-5, 5):
			#var cell_position = Vector3(x,0,z)
			#var item_id = get_cell_item(cell_position)
			#if item_id != -1:
				#print("Kafelek użyty na pozycji:", cell_position, " - ID kafelka:", item_id)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
