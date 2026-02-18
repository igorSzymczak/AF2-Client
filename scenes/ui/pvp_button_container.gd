extends BetterButton

func _on_toggled(toggled_on: bool) -> void:
	g.request_toggle_pvp(toggled_on)
	g.me.pvp = toggled_on

func _on_mouse_entered() -> void:
	g.can_perform_actions = false

func _on_mouse_exited() -> void:
	g.can_perform_actions = true
