extends Node2D

@onready var bullet_manager: Node2D = $BulletManager
var structures: Array[Structure]

@onready var world_environment: WorldEnvironment = %WorldEnvironment
@onready var simple_stars: ColorRect = %SimpleStars


func _ready() -> void:
	g.user_prefs.graphics_changed.connect(_on_graphics_changed)
	_on_graphics_changed(g.user_prefs.graphics)

func get_structure(structure_name: String) -> Structure:
	for structure: Structure in structures:
		if structure.structure_name == structure_name:
			return structure
	push_warning("Structure not found: ", structure_name)
	return null

func _on_graphics_changed(graphics: UserPreferences.Graphics) -> void:
	simple_stars.hide()
	world_environment.environment = null
	if graphics == UserPreferences.Graphics.HIGH:
		world_environment.environment = load("res://scenes/world/Testing/environment.tres")
	# On MEDIUM and HIGH background shader is on
	elif graphics == UserPreferences.Graphics.LOW:
		simple_stars.show()
	elif graphics == UserPreferences.Graphics.POTATO:
		simple_stars.hide()
	
	
