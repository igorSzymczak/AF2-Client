extends Ray

const target_modulation: Color = Color(1,1,1, 0.75)

func _on_ready() -> void:
	#print("Tweening for ", time_to_live)
	
	modulate = Color(1,1,1, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate", target_modulation, time_to_live - 0.1)
	
	await tween.finished
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(self, "modulate", Color(1,1,1, 0.0), 0.1)
	
	await tween_out.finished
	_handle_death()
