extends Control

@export var animation_index := 2

@onready var keybind_button_scene = preload("res://scenes/ui/elements/buttons/keybind_button.tscn")
@onready var action_list = %ActionList

var is_remapping := false
var action_to_remap = null
var remapping_button = null

var input_actions : Dictionary = {
	"Weapon1": "Weapon 1",
	"Weapon2": "Weapon 2",
	"Weapon3": "Weapon 3",
	"Weapon4": "Weapon 4",
	"Weapon5": "Weapon 5",
	"SlowTurn": "Slow Turn",
	"Land": "Land",
	"WeaponChange": "Weapons"
}

@onready var user_prefs := UserPreferences.load_or_create()
func _ready():
	if user_prefs:
		_load_keybinds()
	
	_create_action_list()

func _load_keybinds():
	for action in user_prefs.keybinds:
		var event: InputEventKey = user_prefs.keybinds[action]
		print("Loading: " + action + " binded to " + event.as_text())
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, event)

func _create_action_list():
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button = keybind_button_scene.instantiate()
		var action_label = button.find_child("LabelAction")
		var input_label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events = InputMap.action_get_events(action)
		if !events.is_empty():
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_keybind_button_pressed.bind(button, action))

func _on_keybind_button_pressed(button, action):
	if !is_remapping:
		is_remapping = true
		g.can_perform_actions = false
		action_to_remap = action
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."

func _input(event):
	if is_remapping:
		if (
			event is InputEventKey ||
			(event is InputEventMouseButton and event.is_pressed())
		):
			if event is InputEventMouseButton and event.double_click:
				event.double_click = false
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			if user_prefs:
				user_prefs.keybinds[action_to_remap] = event
				user_prefs.save()
			
			is_remapping = false
			action_to_remap = null
			remapping_button = null
			
			g.can_perform_actions = true
			accept_event()

func _update_action_list(button, event):
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

func _on_reset_button_pressed(): 
	InputMap.load_from_project_settings()
	if user_prefs:
		user_prefs.keybinds = {}
		user_prefs.save()
	_create_action_list()
