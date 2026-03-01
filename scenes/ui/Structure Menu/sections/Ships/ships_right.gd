extends PanelContainer

func _ready() -> void:
	hide()
	slide_out()

func slide_in() -> void:
	if position == Vector2.ZERO:
		return
	show()
	var width: float = size.x
	var screen_size: Vector2 = get_viewport_rect().size
	
	position = Vector2(screen_size.x, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", Vector2(screen_size.x - width, 0), 0.5)
	await tween.finished

func slide_out() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	
	#position = Vector2(screen_size.x, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", Vector2(screen_size.x, 0), 0.5)
	await tween.finished
