extends Button

func _ready():
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	SoundManager.play_sound_from_name_locally("ButtonHover")
