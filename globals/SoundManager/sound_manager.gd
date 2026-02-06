extends Node

@onready var weapons = $Weapons
@onready var entities = $Entities
@onready var bosses = $Bosses
@onready var ui = $UI

var sound_list: Array[AudioStreamPlayer2D] = []
func _ready():
	_build_sound_list()

func _build_sound_list():
	for child: AudioStreamPlayer2D in weapons.get_children():
		sound_list.push_back(child)
	for child: AudioStreamPlayer2D in entities.get_children():
		sound_list.push_back(child)
	for child: AudioStreamPlayer2D in bosses.get_children():
		sound_list.push_back(child)
	for child: AudioStreamPlayer2D in ui.get_children():
		sound_list.push_back(child)

# Server only
@rpc("authority", "call_remote", "reliable")
func _send_sound(index: int, pos: Vector2):
	play_sound(index, pos)

func play_sound(index: int, pos: Vector2):
	var sound_origin: AudioStreamPlayer2D = sound_list[index]
	
	var sound: AudioStreamPlayer2D = sound_origin.duplicate()
	sound.global_position = pos
	add_child(sound)
	sound.play()
	
	sound.connect("finished", Callable(sound, "queue_free"))

func play_sound_from_name(sound_name: String, pos: Vector2) -> void:
	var filtered_sound_list = sound_list.filter(func(sound: AudioStreamPlayer2D): return sound.name == sound_name)
	if filtered_sound_list.is_empty():
		push_error("Sound " + sound_name + " not found!")
	else:
		var sound: AudioStreamPlayer2D = filtered_sound_list[0].duplicate()
		sound.global_position = pos
		add_child(sound)
		sound.play()
	

func play_sound_from_name_locally(sound_name: String):
	if !g.me: return
	var pos: Vector2 = g.me.global_position
	play_sound_from_name(sound_name, pos)
