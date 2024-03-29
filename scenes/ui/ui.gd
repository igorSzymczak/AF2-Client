extends CanvasLayer

@onready var game = $Game
@onready var death = $DeathScreen
@onready var esc_menu = $ESCMenu
@onready var auth_screen = $AuthScreen
@onready var hangar = $HangarMenu


func _ready():
	GlobalSignals.connect("set_ui", set_to)
	GlobalSignals.connect("open_ui", open_ui)
	GlobalSignals.connect("close_current_ui", close_current)
	GlobalSignals.connect("close_all_ui", close_all)
	GlobalSignals.connect("set_ui_args", set_current_args)
	
	#_print_queue()

func _process(_delta):
	handle_changing_menus()

@onready var current_ui = auth_screen
@onready var ui_queue: Array[Control] = [current_ui]

func start_game(): set_to("game")

func to_scene(ui: String):
	if ui.to_lower() == "game": return game
	if ui.to_lower() == "death": return death
	if ui.to_lower() == "esc": return esc_menu
	if ui.to_lower() == "auth": return auth_screen
	if ui.to_lower() == "hangar": return hangar

func set_to(ui: String):
	if to_scene(ui) != current_ui:
		if !ui_queue.is_empty():
			_close_current_ui()
		
		current_ui = to_scene(ui)
		_open_current_ui()

func set_current_args(args: Dictionary):
	if current_ui.has_method("set_args"):
		current_ui.set_args(args)

func open_ui(ui: String):
	current_ui = to_scene(ui)
	_open_current_ui()
	#_print_queue()

func close_current():
	_close_current_ui()
	if ui_queue.is_empty():
		open_ui("game")
	current_ui = ui_queue[-1]
	#_print_queue()

func close_all():
	for _x in ui_queue.size():
		var ui: Control = ui_queue[-1]
		current_ui = ui
		_close_current_ui()

func player_in_game() -> bool:
	return current_ui == game

func is_mouse_over_menu() -> bool:
	var temp: Node2D = Node2D.new()
	add_child(temp)
	var mouse_pos: Vector2 = temp.get_global_mouse_position()
	temp.queue_free()
	for ui in ui_queue:
		if ui == game:
			if game.chat.get_global_rect().has_point(mouse_pos):
				return true
		if ui != game:
			if ui.get_global_rect().has_point(mouse_pos):
				return true
	return false
			

func _print_queue():
	var ui_list = "[ "
	for scene in ui_queue:
		ui_list += scene.name + " "
	ui_list += "]"
	print(ui_list)

func _open_current_ui():
	ui_queue.push_back(current_ui)
	if current_ui.has_method("select_animation"):
		current_ui.select_animation("open")
	else: current_ui.show()

func _close_current_ui():
	if GameManager.local_player and current_ui != game:
		if GameManager.local_player.landed_structure != null:
			GameManager.local_player.request_leave_structure.rpc_id(1, AuthManager.my_username)
	
	if current_ui.has_method("select_animation"):
		current_ui.select_animation("close")
	else: current_ui.hide()
	ui_queue.pop_back()

@onready var chat = game.chat
@onready var default_chat_pos_x = chat.position.x
@onready var chat_message_input = game.chat.message_input
func handle_changing_menus():
	if Input.is_action_just_pressed("Menu"):
		if current_ui == game and GameManager.local_player.landed_structure == null:
			open_ui("esc")
		elif current_ui != auth_screen and current_ui != death:
			close_current()
	if Input.is_action_just_pressed("TypeMessage"):
		if current_ui in [game, esc_menu]:
			if Time.get_ticks_msec() - 10 > chat.last_sent_time:
				if !chat_message_input.has_focus():
					chat_message_input.grab_focus()

	chat.position.x = esc_menu.position.x + esc_menu.menu_width + default_chat_pos_x
