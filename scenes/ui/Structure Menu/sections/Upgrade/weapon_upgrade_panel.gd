class_name WeaponUpgradePanel extends PanelContainer

@onready var entries_container: VBoxContainer = %EntriesContainer

var entry_scene: PackedScene = preload("res://scenes/ui/Structure Menu/sections/Upgrade/weapon_upgrade_entry.tscn")

func load_weapons() -> void:
	var arsenal: Dictionary[WeaponManager.Type, WeaponRuntimeData] = PlayerData.get_prop(PlayerData.Property.ARSENAL)
	
	clear_entries_container()
	for weapon_type: WeaponManager.Type in arsenal.keys():
		var entry: WeaponUpgradeEntry = entry_scene.instantiate()
		
		var weapon_data: WeaponRuntimeData = arsenal[weapon_type]
		var lvl: int  = weapon_data.get_prop(PlayerData.WeaponProperty.LVL)
		var upgrade_costs = weapon_data.get_prop(PlayerData.WeaponProperty.UPGRADE_COSTS)
		upgrade_costs = [] if upgrade_costs == null else upgrade_costs
		
		
		entries_container.add_child(entry)
		entry.init(weapon_type, lvl, upgrade_costs)
	
	slide_in()

func slide_in() -> void:
	if position == Vector2.ZERO:
		return
	show()
	var width: float = size.x
	var screen_size: Vector2 = get_viewport_rect().size
	
	position = Vector2(screen_size.x, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", Vector2(screen_size.x - width, 0), 0.5)
	await tween.finished

func slide_out() -> void:
	var screen_size: Vector2 = get_viewport_rect().size
	
	#position = Vector2(screen_size.x, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(self, "position", Vector2(screen_size.x, 0), 0.5)
	await tween.finished

func clear_entries_container() -> void:
	for child in entries_container.get_children():
		child.free()
