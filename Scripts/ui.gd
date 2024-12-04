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

var original_positions = {}

func _ready() -> void:
	
	for button in resource_buttons:
		button.button_group = resource_group
		button.toggled.connect(_on_toggled.bind(button))
		button.toggled.connect(_on_resource_button_toggled.bind(button))
		
	for button in defence_buttons:
		button.button_group = defence_group
		button.toggled.connect(_on_toggled.bind(button))
		button.toggled.connect(_on_defence_button_toggled.bind(button))
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func update_enemy_count_labels(basic_enemy_num , fast_enemy_num, boss_num):
	basic_enemy_count.text = str(basic_enemy_num)
	fast_enemy_count.text = str(fast_enemy_num)
	boss_enemy_count.text = str(boss_num)


func _on_back_button_pressed() -> void:
	resource_buildings.visible = false
	main_panel.visible = true
	for button in resource_buttons:
		button.button_pressed = false


func _on_back_button_2_pressed() -> void:
	defence_buildings.visible = false
	main_panel.visible = true
	for button in defence_buttons:
		button.button_pressed = false

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

func _on_resource_button_toggled(is_pressed: bool, button):
	match button.name:
		"Wood building":
			game_script.wood_build = is_pressed
		"Wheat building":
			game_script.wheat_build = is_pressed
		"Stone building":
			game_script.stone_build = is_pressed
		"Beer building":
			game_script.beer_build = is_pressed
func _on_defence_button_toggled(is_pressed: bool, button):
	match button.name:
		"Walls build button":
			game_script.walls_build = is_pressed
		"Normal Tower button":
			game_script.normal_tower_build = is_pressed
		"Freeze Tower button":
			game_script.freeze_tower_build = is_pressed
		"AOE Tower":
			game_script.aoe_tower_build = is_pressed
