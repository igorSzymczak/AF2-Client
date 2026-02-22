extends Node

@rpc("authority", "call_remote", "reliable")
func add_arsenal_weapon(weapon_data: Dictionary) -> void:
	_handle_add_arsenal_weapon(weapon_data)

func _handle_add_arsenal_weapon(dict_data: Dictionary) -> void:
	var weapon_data := WeaponRuntimeData.new()
	weapon_data.from_dict(dict_data)
	
	var weapon_type: WeaponManager.Type = weapon_data.get_prop(PlayerData.WeaponProperty.WEAPON_TYPE)
	PlayerData.add_arsenal_weapon(weapon_type, weapon_data)
