class_name UserPreferences extends Resource

@export_range(0, 1, 0.1) var music_audio_level: float = 0.5
@export_range(0, 1, 0.1) var effects_audio_level: float = 0.5
@export_range(0, 1, 0.1) var interface_audio_level: float = 0.5
@export_range(0, 1, 0.1) var ambience_audio_level: float = 0.5

@export var last_username: String

@export var disable_mouse_aim: bool = false
@export var reticle: bool = false

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")

static func load_or_create() -> UserPreferences:
	if FileAccess.file_exists("user://user_prefs.tres"):
		return load("user://user_prefs.tres") as UserPreferences
	else:
		return UserPreferences.new()
