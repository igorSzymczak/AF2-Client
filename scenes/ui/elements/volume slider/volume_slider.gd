extends HSlider

@export var bus_name: String

var bus_index: int

func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	mouse_entered.connect(_on_hover)

#func _on_value_changed(value: float):
	#AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))

func _on_hover():
	SoundManager.play_sound_from_name_locally("ButtonHover")
