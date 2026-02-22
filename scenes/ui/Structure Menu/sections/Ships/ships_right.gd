extends PanelContainer

var initial_position: Vector2
var width: float
func _ready() -> void:
	width = get_rect().size.x
	initial_position = Vector2(get_viewport_rect().size.x - width, 0.0)
	
	hide()
	slide_out()

func slide_in() -> void:
	show()
	position = initial_position + Vector2(width, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", initial_position, 1.0)

func slide_out() -> void:
	position = initial_position
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", initial_position + Vector2(width, 0.0), 1.0)
	await tween.finished
	hide()
