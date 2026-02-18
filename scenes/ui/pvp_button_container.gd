extends BetterButton

func _on_toggled(toggled_on: bool) -> void:
	g.request_toggle_pvp(toggled_on)
	g.me.pvp = toggled_on
