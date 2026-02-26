extends Node

@rpc("authority", "call_remote", "reliable")
func add_arsenal_weapon(weapon_data: Dictionary) -> void:
	_handle_add_arsenal_weapon(weapon_data)

@rpc("authority", "call_remote", "reliable")
func add_hotbar_weapon(weapon_data: Dictionary) -> void:
	_handle_add_hotbar_weapon(weapon_data)

@rpc("authority", "call_remote", "reliable")
func _send_player_data_to_client(data: Dictionary) -> void:
	_handle_player_data_sent(data)

@rpc("authority", "call_remote", "reliable")
func _update_hotbar_weapon_property(slot: int, prop: PlayerData.WeaponProperty, value: Variant) -> void:
	_handle_update_hotbar_weapon_property(slot, prop, value)

@rpc("authority", "call_remote", "reliable")
func _update_arsenal_weapon_property(weapon_type: WeaponManager.Type, prop: PlayerData.WeaponProperty, value: Variant) -> void:
	_handle_update_arsenal_weapon_property(weapon_type, prop, value)

func _handle_add_arsenal_weapon(dict_data: Dictionary) -> void:
	var weapon_data := WeaponRuntimeData.new()
	weapon_data.from_dict(dict_data)
	
	var weapon_type: WeaponManager.Type = weapon_data.get_prop(PlayerData.WeaponProperty.WEAPON_TYPE)
	PlayerData.add_arsenal_weapon(weapon_type, weapon_data)

func _handle_add_hotbar_weapon(dict_data: Dictionary) -> void:
	var weapon_data := WeaponRuntimeData.new()
	weapon_data.from_dict(dict_data)
	
	
	var hotbar: Dictionary[int, WeaponRuntimeData] = PlayerData.get_prop(PlayerData.Property.HOTBAR)
	var slot: int = hotbar.size() + 1
	PlayerData.add_hotbar_weapon(slot, weapon_data)
	print("Added hotbar weapon at slot ", slot)


func _handle_player_data_sent(data: Dictionary) -> void:
	PlayerData.from_dict(data)

func _handle_update_hotbar_weapon_property(slot: int, prop: PlayerData.WeaponProperty, value: Variant):
	var runtime_data: WeaponRuntimeData = PlayerData.get_hotbar_weapon(slot)
	runtime_data.set_prop(prop, value)

func _handle_update_arsenal_weapon_property(weapon_type: WeaponManager.Type, prop: PlayerData.WeaponProperty, value: Variant):
	var runtime_data: WeaponRuntimeData = PlayerData.get_arsenal_weapon(weapon_type)
	runtime_data.set_prop(prop, value)
