extends Node


# Bullets
signal bullet_fired(bullet: Bullet, position: Vector2, direction: Vector2, team, shooter)

# Minimap
signal give_main_player(main_player: Player)

# Camera zooming stuff
signal camera_zoom(scale: float)
signal camera_offset(offset: float)

# Player's UI Stats
signal player_health(health: float)
signal player_shield(shield: float)

# Eplosions
signal create_explosion(pos: Vector2, type: String, quantity: int, args: Dictionary)

# Boss healthBar
signal boss_max_health(health: int)
signal boss_health(health: int)
signal boss_max_shield(health: int)
signal boss_shield(health: int)

# Sounds
signal play_sound(sound: AudioStreamPlayer2D)

# UI
signal set_ui(ui: String)
signal set_ui_args(args: Dictionary)
signal open_ui(ui: String)
signal close_current_ui()
signal close_all_ui()
