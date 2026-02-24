class_name UpgradePointIcon extends TextureRect


var selected_color: Color = Color(0, 1, 0)
var blank_color: Color = Color(0.188, 0.188, 0.188)

var selected : bool = false : set = set_selected
const animation_length_seconds: float = 0.5

signal finished_animation

func _ready() -> void:
	texture = texture.duplicate(true)

func set_selected(value: bool) -> void:
	selected = value
	if selected:
		_select()
	else:
		set_start_color(blank_color)
		set_end_color(blank_color)

func _select() -> void:
	var tween_start: Tween = create_tween()
	tween_start.tween_method(set_start_color, blank_color, selected_color, animation_length_seconds / 2.0)
	var tween_end: Tween = create_tween()
	tween_end.tween_method(set_end_color, blank_color, selected_color, animation_length_seconds)
	await tween_end.finished
	finished_animation.emit()

func select_no_animation() -> void:
	set_start_color(selected_color)
	set_end_color(selected_color)

func set_start_color(color: Color) -> void:
	var gradient: Gradient = texture.gradient
	gradient.set_color(0, color)

func set_end_color(color: Color) -> void:
	var gradient: Gradient = texture.gradient
	gradient.set_color(1, color)
