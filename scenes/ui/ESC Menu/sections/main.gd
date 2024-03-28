extends Control

@export var animation_index: int = 1

func _on_quit_button_pressed():
	get_tree().quit()
