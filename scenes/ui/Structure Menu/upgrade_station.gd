extends Control

@export var animation_index: int = 1
@export var weapon_upgrade_panel: WeaponUpgradePanel

func load_upgrades() -> void:
	weapon_upgrade_panel.load_weapons()
