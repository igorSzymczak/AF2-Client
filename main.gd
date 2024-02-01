extends Node2D

@onready var bullet_manager: Node2D = $BulletManager
@onready var player: CharacterBody2D = $Player

func _ready() -> void:
	player.connect("player_fired_weapon", bullet_manager.handle_bullet_spawned)
