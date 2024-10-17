extends GridMap

var block_type = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#print_used_tiles()
	pass
	

func place_block(position_vec: Vector3):
	if can_place_block(position_vec):
		self.set_cell_item(position_vec,block_type)
		print("Bloczek postawiony na pozycji: ", position_vec)
	

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
