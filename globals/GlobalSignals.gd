extends Node

# Minimap
signal give_main_player(main_player: Player)

# Camera zooming stuff
signal camera_zoom(scale: float)
signal camera_offset(offset: float)

# Eplosions
signal create_explosion(pos: Vector2, type: String, quantity: int, args: Dictionary)

# Boss healthBar
signal boss_max_health(health: int)
signal boss_health(health: int)
signal boss_max_shield(health: int)
signal boss_shield(health: int)

# UI
signal set_ui(ui: String)
signal set_ui_args(args: Dictionary)
signal open_ui(ui: String)
signal close_current_ui()
signal close_all_ui()
