extends Control

@onready var chat = $Chat

var selected_animation = null
var animation_finished = true
func select_animation(animation_name: String):
	if animation_finished:
		if animation_name == "open":
			animation_finished = false
			show()
			var scale_tween: Tween = create_tween()
			scale_tween.tween_property(self, "modulate:a", 1.0, 0.3)
			
			await get_tree().create_timer(0.3).timeout
			animation_finished = true
			
		elif animation_name == "close":
			animation_finished = false
			var scale_tween: Tween = create_tween()
			scale_tween.tween_property(self, "modulate:a", 0.0, 0.3)
			
			await get_tree().create_timer(0.3).timeout
			hide()
			animation_finished = true
