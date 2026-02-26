class_name UpgradeButtonSelect extends Button

@onready var texture: TextureRect = $TextureRect

var select_color: Color = Color(1,1,1, 0.25)
var regular_color: Color = Color(1,1,1, 0.0)

var selected: bool : set = set_selected

func set_selected(value: bool):
	if disabled: return
	
	selected = value
	if selected: _select()
	else: _deselect()

func _select() -> void:
	texture.modulate = select_color
	button_pressed = true

func _deselect() -> void:
	texture.modulate = regular_color
	button_pressed = false
