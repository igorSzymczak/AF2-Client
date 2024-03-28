class_name UserPreferences extends Resource

@export_range(0, 1, 0.1) var music_audio_level: float = 0.5
@export_range(0, 1, 0.1) var effects_audio_level: float = 0.5
@export_range(0, 1, 0.1) var interface_audio_level: float = 0.5
@export_range(0, 1, 0.1) var ambience_audio_level: float = 0.5
@export var nickname: String
@export var default_auth_screen: String = "register"

func save() -> void:
	ResourceSaver.save(self, "user://user_prefs.tres")

static func load_or_create() -> UserPreferences:
	var res: UserPreferences = load("user://user_prefs.tres") as UserPreferences
	if !res:
		res = UserPreferences.new()
	return res
