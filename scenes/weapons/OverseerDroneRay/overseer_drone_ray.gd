extends Ray

@onready var gradient_line: Line2D = $GradientLine

func _on_ready() -> void:
	scale = Vector2(1.0, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	
	await get_tree().create_timer(time_to_live - 0.1).timeout
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(self, "scale", Vector2(1.0, 0.0), 0.1)

func set_radius(value: float) -> void:
	if !base_line or !gradient_line:
		return
	
	radius = value
	base_line.set_width(radius)
	gradient_line.set_width(radius * 6.0)
