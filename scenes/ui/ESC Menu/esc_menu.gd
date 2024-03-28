extends Control

@onready var menu_width = 300.0
@onready var main_section = $PanelContainer/MarginContainer/Main
@onready var settings_section = $PanelContainer/MarginContainer/Settings

@onready var current_section: Control = main_section
@onready var default_section_pos_x: float = 30.0
func _ready():
	position.x = -menu_width

func _process(delta):
	play_current_animation(delta)

var animation_finished = true
var selected_animation = null
func select_animation(animation_name: String):
	if animation_name == "open":
		selected_animation = "open"
		animation_finished = false
	elif animation_name == "close":
		selected_animation = "close"
		animation_finished = false
	elif animation_name == "settings":
		if current_section != settings_section and animation_finished:
			selected_animation = "settings"
			animation_finished = false
	elif animation_name == "main":
		if current_section != main_section and animation_finished:
			selected_animation = "main"
			animation_finished = false

func play_current_animation(delta: float):
	if !animation_finished:
		if selected_animation == "open":
			show()
			current_section.hide()
			current_section = main_section
			current_section.show()
			position.x = lerpf(position.x, 0.0, delta * 10)
			if position.x >= -1:
				position.x = 0
				animation_finished = true
		elif selected_animation == "close":
			position.x = lerpf(position.x, -menu_width, delta * 10)
			if position.x <= -menu_width + 1:
				position.x = - menu_width
				animation_finished = true
				hide()
		elif selected_animation == "settings":
			hide_current_and_show(delta, settings_section)
		elif selected_animation == "main":
			hide_current_and_show(delta, main_section)

var hide_show_finished = true
func hide_current_and_show(delta, selected_section: Control):
	if selected_section.animation_index >= current_section.animation_index: 
		# Swipe everything to Left
		if hide_show_finished:
			hide_show_finished = false
			selected_section.show()
			current_section.position.x = default_section_pos_x
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 0.0
		
		current_section.position.x = lerpf(current_section.position.x, - menu_width, delta * 10)
		current_section.modulate.a = lerpf(selected_section.modulate.a, 0.0, delta * 10)
		
		selected_section.modulate.a = lerpf(selected_section.modulate.a, 1.0, delta * 10)
		
		if selected_section.modulate.a >= 0.99:
			animation_finished = true
			hide_show_finished = true
			current_section.position.x = default_section_pos_x
			current_section.hide()
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 1.0
			
			current_section = selected_section
			
	elif selected_section.animation_index < current_section.animation_index:
		# Swipe everything to Right
		if hide_show_finished:
			hide_show_finished = false
			selected_section.show()
			current_section.position.x = default_section_pos_x
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 0.0
		
		current_section.position.x = lerpf(current_section.position.x, menu_width, delta * 10)
		current_section.modulate.a = lerpf(selected_section.modulate.a, 0.0, delta * 10)
		
		selected_section.modulate.a = lerpf(selected_section.modulate.a, 1.0, delta * 10)
		
		if selected_section.modulate.a >= 0.99:
			animation_finished = true
			hide_show_finished = true
			current_section.position.x = default_section_pos_x
			current_section.hide()
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 1.0
			
			current_section = selected_section

func _on_settings_button_button_down(): select_animation("settings")
func _on_return_to_main_button_pressed(): select_animation("main")
