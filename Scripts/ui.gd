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
@onready var resource_buttons = [$"Bottom_panel/Resource buildings/HBoxContainer/Wood building", $"Bottom_panel/Resource buildings/HBoxContainer/Wheat building", $"Bottom_panel/Resource buildings/HBoxContainer/Stone building", $"Bottom_panel/Resource buildings/HBoxContainer/Beer building", $"Bottom_panel/Resource buildings/HBoxContainer/Workers" ]
# Called when the node enters the scene tree for the first time.

@onready var game_script = get_parent().get_parent()

@onready var wood_count_label: Label = $"EQ container/MarginContainer/GridContainer/Wood count label"
@onready var wheat_count_label: Label = $"EQ container/MarginContainer/GridContainer/Wheat count label"
@onready var stone_count_label: Label = $"EQ container/MarginContainer/GridContainer/Stone count label"
@onready var beer_count_label: Label = $"EQ container/MarginContainer/GridContainer/Beer count label"
@onready var worker_count_label : Label = $"EQ container/MarginContainer/GridContainer/Worker count label"

@onready var skip_button: Button = $skip_button

@onready var worker_bonus_panel = $Workers_buy

@onready var menu_buttons: PanelContainer = $"../Menu/Menu Buttons"
@onready var how_to_play: Control = $"../Menu/How to Play"
@onready var title: Label = $"../Menu/Title"


var full_heart = load("res://Resources/Icons/Heart.png")
var empty_heart = load("res://Resources/Icons/black_heart.png")
var slow_png = load("res://Resources/Icons/snowflake.png")
var aoe_png = load("res://Resources/Icons/catapult.png")

var info_panels = preload("res://Scenes/buttons_info_panels.tscn")
var tower_info = preload("res://Scenes/towers_info_panels.tscn")
var panel_info_holder
var ui_tower_panel

var original_positions = {}
var panel_number
@onready var locked_buttons = [$"Bottom_panel/Resource buildings/HBoxContainer/Workers", $"Bottom_panel/Resource buildings/HBoxContainer/Wheat building", $"Bottom_panel/Resource buildings/HBoxContainer/Beer building"]

func _ready() -> void:
	panel_info_holder = null
	ui_tower_panel = null
	worker_bonus_panel.position.x += 235
	worker_bonus_panel.position.y -= 179
			
	for button in resource_buttons:
		button.button_group = resource_group
		button.toggled.connect(_on_toggled.bind(button))
		button.toggled.connect(_on_resource_button_toggled.bind(button))
		
	for button in defence_buttons:
		button.button_group = defence_group
		button.toggled.connect(_on_toggled.bind(button))
		button.toggled.connect(_on_defence_button_toggled.bind(button))

	#locking stuff that is unlockable during the game
	for button in locked_buttons:
		button.disabled = true
		for child in button.get_children():
			if child is TextureRect:
				if not original_positions.has(child):
					original_positions[child] = child.position.y
			var target_position = child.position
			if button.disabled:
				target_position.y = original_positions[child] + 20
				child.position = target_position

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
	worker_count_label.set_text("%d/%d" % [game_script.game_resources.used_workers, game_script.game_resources.workers])
		
	if panel_info_holder != null and panel_number == 7:
		panel_info_holder.get_child(7).get_child(1).get_child(4).get_node("Wood").text = str(2*(game_script.number_of_tetris_placed + 1))
		panel_info_holder.get_child(7).get_child(1).get_child(4).get_node("Stone").text = str(2*(game_script.number_of_tetris_placed + 1))
	if panel_info_holder != null and panel_number == 8:
		panel_info_holder.get_child(8).get_child(1).get_child(2).get_node("Wheat").text = str(30 * (game_script.game_resources.workers - 2))
		if game_script.is_enough_resources(0,0,30 * (game_script.game_resources.workers - 2),0,0):
			worker_bonus_panel.get_child(1).get_child(2).get_child(0).disabled = false
		else:
			worker_bonus_panel.get_child(1).get_child(2).get_child(0).disabled = true
	else:
		worker_bonus_panel.visible = false

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
		"Workers":
			#kup workera
			worker_bonus_panel.visible = true
			worker_bonus_panel.get_child(1).get_child(2).get_child(2).disabled = false
			panel_number = 8
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
			panel_number = 7
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
			
			
#when clicked on tower signal is recieved and pops up the ui for stats/upgrade/destroy
func _on_normal_tower_lvl_1_tower_info(obj) -> void:
	#print("Signal recieved from: ",obj.name)
	if not game_script.normal_tower_build and not game_script.freeze_tower_build and not game_script.aoe_tower_build and not game_script.wood_build and not game_script.stone_build and not game_script.wheat_build and not game_script.beer_build and game_script.is_build_phase:
		if ui_tower_panel == null:
			obj.get_node("MobDetector").visible = true
			ui_tower_panel = tower_info.instantiate()
			add_child(ui_tower_panel)
			var help_panel
			var needed_wood = 0
			var needed_stone = 0
			var needed_wheat = 0
			if obj.level == 1:
				needed_wood = obj.wood_to_upgrade_lvl2
				needed_stone = obj.stone_to_upgrade_lvl2
				needed_wheat = obj.wheat_to_upgrade_lvl2
			elif obj.level == 2:
				needed_wood = obj.wood_to_upgrade_lvl3
				needed_stone = obj.stone_to_upgrade_lvl3
				needed_wheat = obj.wheat_to_upgrade_lvl3
			help_panel = ui_tower_panel.get_child(0)
			help_panel.visible = true
			help_panel.size.x-=10
			help_panel.object = obj
			help_panel.connect("X_button_pressed",self._on_X_button)
			help_panel.connect("upgrade_pressed",self.upgrade_tower)
			help_panel.get_child(1).get_child(0).get_child(1).text = str(obj.title)
			help_panel.get_child(1).get_child(1).get_node("Dmg").text = str(obj.damage)
			help_panel.get_child(1).get_child(1).get_node("Range").text = str(obj.tower_range)
			help_panel.get_child(1).get_child(1).get_node("Lvl").text = str(obj.level)
			help_panel.get_child(1).get_child(1).get_node("Health").text = str(obj.health)
			help_panel.get_child(1).get_child(1).get_node("FireRate").text = str(obj.firerate)+"/sec"
			help_panel.get_child(1).get_child(1).get_child(0).get_child(0).size.x = help_panel.size.x/2 + 25
			if obj.title == "Normal Tower":
				help_panel.get_child(1).get_child(1).get_node("Special thing").visible = false
				help_panel.get_child(1).get_child(1).get_node("Special thing_png").visible = false
				help_panel.get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_node("Name6").visible = false
			if obj.title == "Freeze Tower":
				help_panel.get_child(1).get_child(1).get_node("Special thing").text = str(obj.slow*100)+"%"
				help_panel.get_child(1).get_child(1).get_node("Special thing_png").texture = slow_png
				help_panel.get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_node("Name6").text = "slow"
			if obj.title == "AOE Tower":
				help_panel.get_child(1).get_child(1).get_node("Special thing").text = str(obj.aoe*100)+"%"
				help_panel.get_child(1).get_child(1).get_node("Special thing_png").texture = aoe_png
				help_panel.get_child(1).get_child(1).get_child(0).get_child(0).get_child(0).get_node("Name6").text = "AOE dmg"
			if obj.level == 1:
				help_panel.get_child(1).get_child(2).get_node("Wood").text = str(obj.wood_to_upgrade_lvl2)
				help_panel.get_child(1).get_child(2).get_node("Stone").text = str(obj.stone_to_upgrade_lvl2)
				help_panel.get_child(1).get_child(2).get_node("Wheat").text = str(obj.wheat_to_upgrade_lvl2)
			elif obj.level == 2:
				help_panel.get_child(1).get_child(2).get_node("Wood").text = str(obj.wood_to_upgrade_lvl3)
				help_panel.get_child(1).get_child(2).get_node("Stone").text = str(obj.stone_to_upgrade_lvl3)
				help_panel.get_child(1).get_child(2).get_node("Wheat").text = str(obj.wheat_to_upgrade_lvl3)
			else:
				help_panel.get_child(1).get_child(2).get_node("Label").text = "MAX LEVEL!"
				for i in help_panel.get_child(1).get_child(2).get_child_count():
					if i>0:
						help_panel.get_child(1).get_child(2).get_child(i).visible = false
			help_panel.get_child(1).get_child(4).get_node("Wood").text = "+"+str(obj.return_wood * obj.level)
			help_panel.get_child(1).get_child(4).get_node("Stone").text = "+"+str(obj.return_stone * obj.level)
			if not game_script.is_enough_resources(needed_wood,needed_stone,needed_wheat,0,0) or obj.level == 3:
				help_panel.get_child(1).get_child(3).disabled = true
			else:
				help_panel.get_child(1).get_child(3).disabled = false
		else:
			print("One panel already opened")


#Signal recived when X_button on tower_panel is clicked
func _on_X_button() ->void:
	if ui_tower_panel !=null:
		ui_tower_panel.get_child(0).object.get_node("MobDetector").visible = false
		ui_tower_panel.queue_free()
		ui_tower_panel = null
		
		
func upgrade_tower(tower) ->void:
	#print("upgrading: ",tower)
	_on_X_button()
	if tower.level == 1:
		game_script.game_resources.wood -= tower.wood_to_upgrade_lvl2
		game_script.game_resources.stone -= tower.stone_to_upgrade_lvl2
		game_script.game_resources.wheat -= tower.wheat_to_upgrade_lvl2
	elif tower.level == 2:
		game_script.game_resources.wood -= tower.wood_to_upgrade_lvl3
		game_script.game_resources.stone -= tower.stone_to_upgrade_lvl3
		game_script.game_resources.wheat -= tower.wheat_to_upgrade_lvl3
	tower.upgrade()

func switch_skip_button_visiblity() -> void:
	if skip_button.visible == true:
		skip_button.visible = false
	else:
		skip_button.visible = true

#closing bonus worker panel
func _on_no_pressed() -> void:
	panel_number = 0
	worker_bonus_panel.get_child(1).get_child(2).get_child(0).disabled = true
	worker_bonus_panel.get_child(1).get_child(2).get_child(2).disabled = true
	$"Bottom_panel/Resource buildings/HBoxContainer/Workers".set_pressed_no_signal(false)
	worker_bonus_panel.visible = false
	for child in $"Bottom_panel/Resource buildings/HBoxContainer/Workers".get_children():
		var target_position = child.position
		target_position.y = original_positions[child]
		child.position = target_position


func _on_about_pressed() -> void:
	if !how_to_play.visible:
		how_to_play.visible = true
		title.global_position.x -= 500
		menu_buttons.global_position.x -= 500
	


func _on_close_pressed() -> void:
	how_to_play.visible = false
	title.global_position.x += 500
	menu_buttons.global_position.x += 500


func _button_to_main_menu() -> void:
	get_tree().reload_current_scene()


func _on_quit_in_pause_pressed() -> void:
	get_tree().paused = false
	_button_to_main_menu()
