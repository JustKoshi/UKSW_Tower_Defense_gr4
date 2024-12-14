extends Control

@onready var basic_enemy_count = $"EnemyPanelContainer/MarginContainer/GridContainer/BE count Label"
@onready var fast_enemy_count = $"EnemyPanelContainer/MarginContainer/GridContainer/FE count Label"
@onready var boss_enemy_count = $"EnemyPanelContainer/MarginContainer/GridContainer/Boss count Label"

@onready var bottom_panel: PanelContainer = $Bottom_panel

@onready var main_panel: MarginContainer = $"Bottom_panel/Main panel"
@onready var defence_buildings: MarginContainer = $"Bottom_panel/Defence buildings"
@onready var resource_buildings: MarginContainer = $"Bottom_panel/Resource buildings"

var resource_group = ButtonGroup.new()
var defence_group = ButtonGroup.new()
@onready var defence_buttons= [$"Bottom_panel/Defence buildings/HBoxContainer/Walls build button", $"Bottom_panel/Defence buildings/HBoxContainer/Normal Tower button", $"Bottom_panel/Defence buildings/HBoxContainer/Freeze Tower button", $"Bottom_panel/Defence buildings/HBoxContainer/AOE Tower"]
@onready var resource_buttons = [$"Bottom_panel/Resource buildings/HBoxContainer/Wood building", $"Bottom_panel/Resource buildings/HBoxContainer/Wheat building", $"Bottom_panel/Resource buildings/HBoxContainer/Stone building", $"Bottom_panel/Resource buildings/HBoxContainer/Beer building" ]
# Called when the node enters the scene tree for the first time.

@onready var game_script = get_parent().get_parent()

@onready var wood_count_label: Label = $"EQ container/MarginContainer/GridContainer/Wood count label"
@onready var wheat_count_label: Label = $"EQ container/MarginContainer/GridContainer/Wheat count label"
@onready var stone_count_label: Label = $"EQ container/MarginContainer/GridContainer/Stone count label"
@onready var beer_count_label: Label = $"EQ container/MarginContainer/GridContainer/Beer count label"

var full_heart = load("res://Resources/Icons/Heart.png")
var empty_heart = load("res://Resources/Icons/black_heart.png")

var info_panels = preload("res://Scenes/buttons_info_panels.tscn")
var panel_info_holder

var original_positions = {}
var panel_number

func _ready() -> void:
	panel_info_holder = null
	
	for button in resource_buttons:
		button.button_group = resource_group
		button.toggled.connect(_on_toggled.bind(button))
		button.toggled.connect(_on_resource_button_toggled.bind(button))
		
	for button in defence_buttons:
		button.button_group = defence_group
		button.toggled.connect(_on_toggled.bind(button))
		button.toggled.connect(_on_defence_button_toggled.bind(button))

	#Setting up hearts
	for i in range(game_script.max_health):
		var heart = TextureRect.new()
		heart.texture = full_heart
		heart.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		get_node("HP container").get_child(0).get_child(0).add_child(heart)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#setting resources values
	wood_count_label.set_text("%d" % game_script.game_resources.wood)
	stone_count_label.set_text("%d" % game_script.game_resources.stone)
	wheat_count_label.set_text("%d" % game_script.game_resources.wheat)
	beer_count_label.set_text("%d" % game_script.game_resources.beer)

func update_enemy_count_labels(basic_enemy_num , fast_enemy_num, boss_num):
	basic_enemy_count.text = str(basic_enemy_num)
	fast_enemy_count.text = str(fast_enemy_num)
	boss_enemy_count.text = str(boss_num)


func _on_back_button_pressed() -> void:
	resource_buildings.visible = false
	main_panel.visible = true
	for button in resource_buttons:
		button.button_pressed = false
	game_script.current_cam_index = 0
	game_script.set_camera()
	if panel_info_holder != null:
			panel_info_holder.free()
			panel_info_holder = null

func _on_back_button_2_pressed() -> void:
	defence_buildings.visible = false
	main_panel.visible = true
	for button in defence_buttons:
		button.button_pressed = false
	game_script.current_cam_index = 0
	game_script.set_camera()
	if panel_info_holder != null:
			panel_info_holder.free()
			panel_info_holder = null
	
func _on_resource_build_button_pressed() -> void:
	main_panel.visible = false
	resource_buildings.visible = true


func _on_defence_build_pressed() -> void:
	main_panel.visible = false
	defence_buildings.visible = true

#Fits position of images next to buttons
func _on_toggled(is_pressed: bool, button):
	for child in button.get_children():
		if child is TextureRect:
			if not original_positions.has(child):
				original_positions[child] = child.position.y
		var target_position = child.position
		if is_pressed:
			target_position.y = original_positions[child] + 20
		else:
			target_position.y = original_positions[child]
		child.position = target_position

func show_first_panel():
	
	if main_panel.visible != true:
		main_panel.visible = true
	if defence_buildings.visible == true:
		defence_buildings.visible = false
	if resource_buildings.visible == true:
		resource_buildings.visible = false
	unpress_all_buttons()
	
func unpress_all_buttons():
	for button in resource_buttons:
		button.button_pressed = false
	for button in defence_buttons:
		button.button_pressed = false
	if panel_info_holder != null:
			panel_info_holder.free()
			panel_info_holder = null

func _on_resource_button_toggled(is_pressed: bool, button):
	match button.name:
		"Wood building":
			game_script.wood_build = is_pressed
			panel_number = 3
		"Wheat building":
			game_script.wheat_build = is_pressed
			panel_number = 4
		"Stone building":
			game_script.stone_build = is_pressed
			panel_number = 5
		"Beer building":
			game_script.beer_build = is_pressed
			panel_number = 6
	if panel_number >= 0:
		if panel_info_holder != null:
			panel_info_holder.free()
		panel_info_holder = info_panels.instantiate()
		add_child(panel_info_holder)
		for i in panel_info_holder.get_child_count():
			if i == panel_number:
				panel_info_holder.get_child(i).visible = true
			else:
				panel_info_holder.get_child(i).visible = false
	else:
		if panel_info_holder != null:
			panel_info_holder.free()
			panel_info_holder = null
			

func _on_defence_button_toggled(is_pressed: bool, button):
	match button.name:
		"Walls build button":
			game_script.walls_build = is_pressed
			panel_number = -1
		"Normal Tower button":
			game_script.normal_tower_build = is_pressed
			panel_number=0
		"Freeze Tower button":
			game_script.freeze_tower_build = is_pressed
			panel_number=1
		"AOE Tower":
			game_script.aoe_tower_build = is_pressed
			panel_number=2
	if panel_number >= 0:
		if panel_info_holder != null:
			panel_info_holder.free()
		panel_info_holder = info_panels.instantiate()
		add_child(panel_info_holder)
		for i in panel_info_holder.get_child_count():
			if i == panel_number:
				panel_info_holder.get_child(i).visible = true
			else:
				panel_info_holder.get_child(i).visible = false
	else:
		if panel_info_holder != null:
			panel_info_holder.free()
			panel_info_holder = null

func update_hearts() -> void:
	for i in range(game_script.max_health):
		var heart = get_node("HP container").get_child(0).get_child(0).get_child(i+1) as TextureRect
		if i < game_script.current_health:
			heart.texture = full_heart
		else:
			heart.texture = empty_heart
