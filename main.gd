extends Node2D

@onready var bullet_manager: Node2D = $BulletManager

func _ready() -> void:
	GlobalSignals.connect("bullet_fired", bullet_manager.handle_bullet_spawned)
