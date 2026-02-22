extends Control

@onready var menu_width = 350.0
@onready var main_section = $PanelContainer/MarginContainer/Main
@onready var settings_section = $PanelContainer/MarginContainer/Settings
@onready var keybinds_section = $PanelContainer/MarginContainer/Keybinds

@onready var current_section: Control = main_section
var next_section: Control
var previous_section: Control
@onready var padding: float = 30.0
func _ready():
	position.x = -menu_width
	main_section.show()

func select_animation(animation_name: String):
	if animation_name == "open":
		#hide_section(current_section)
		show_self()
	elif animation_name == "close":
		hide_self()
	elif animation_name == "settings":
		next_section = settings_section
		hide_section(current_section)
		show_section(next_section)
	elif animation_name == "keybinds":
		next_section = keybinds_section
		hide_section(current_section)
		show_section(next_section)
	elif animation_name == "weapons":
		GlobalSignals.close_current_ui.emit()
		GlobalSignals.open_ui.emit("weapon_change")
		hide_section(current_section)
		hide_self()
	elif animation_name == "main":
		next_section = main_section
		hide_section(current_section)
		show_section(next_section)
	elif animation_name == "cargo":
		GlobalSignals.open_ui.emit("cargo")
		hide_section(current_section)
		hide_self()

func hide_section(section: Control) -> void:
	if section == null:
		return
	
	var final_x: float = -menu_width + padding * 2.0
	if next_section:
		if next_section.animation_index < section.animation_index:
			final_x = menu_width
	
	var tween: Tween = create_tween()
	tween.tween_property(section, "position", Vector2(final_x, padding), 0.1)
	await tween.finished
	section.hide()
	
	previous_section = section

func hide_self() -> void:
	hide_section(current_section)
	var width: float = menu_width
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", Vector2(-width, 0.0), 0.1)
	await tween.finished
	hide()

func show_self() -> void:
	current_section = main_section
	
	main_section.position = Vector2(padding, padding)
	main_section.show()
	show()
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "position", Vector2.ZERO, 0.1)
	await tween.finished
	show()
	main_section.show()

func show_section(section: Control) -> void:
	if section == null:
		return
	next_section = null
	current_section = section
	
	var final_x: float = -menu_width + padding * 2.0
	if previous_section:
		if previous_section.animation_index < section.animation_index:
			final_x = menu_width
	
	section.show()
	section.position = Vector2(final_x, padding)
	var tween: Tween = create_tween()
	tween.tween_property(section, "position", Vector2(padding, padding), 0.1)
	await tween.finished
	section.show()
	
	previous_section = null

func _on_settings_button_button_down(): select_animation("settings")
func _on_keybinds_button_pressed():select_animation("keybinds")
func _on_return_to_main_button_pressed(): select_animation("main")
func _on_weapons_button_pressed(): select_animation("weapons")
func _on_cargo_button_pressed(): select_animation("cargo")
