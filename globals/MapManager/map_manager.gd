extends Node

var pois: Array[POI]

signal poi_created(poi: POI)
signal poi_visibility_updated(id: int, visible: bool)
signal poi_rotation_updated(id: int, rotation: Vector2)
signal poi_position_updated(id: int, position: Vector2)
signal poi_label_updated(id:int, label: String)
signal poi_removed(id: int)

func create_poi_icon(type: POI.TYPE) -> Node2D:
	match type:
		POI.TYPE.PLAYER: return load("res://scenes/ui/POI Icons/player_icon.tscn").instantiate()
		POI.TYPE.SPAWNER: return load("res://scenes/ui/POI Icons/spawner_icon.tscn").instantiate()
		POI.TYPE.ENEMY: return load("res://scenes/ui/POI Icons/enemy_icon.tscn").instantiate()
		POI.TYPE.ALLY: return load("res://scenes/ui/POI Icons/ally_icon.tscn").instantiate()
		POI.TYPE.BOSS: return load("res://scenes/ui/POI Icons/boss_icon.tscn").instantiate()
		POI.TYPE.PLANET: return load("res://scenes/ui/POI Icons/planet_icon.tscn").instantiate()
		POI.TYPE.HANGAR: return load("res://scenes/ui/POI Icons/hangar_icon.tscn").instantiate()
		POI.TYPE.SUN: return load("res://scenes/ui/POI Icons/sun_icon.tscn").instantiate()
		POI.TYPE.ITEM: return load("res://scenes/ui/POI Icons/item_icon.tscn").instantiate()
		POI.TYPE.RECYCLE_STATION: return load("res://scenes/ui/POI Icons/recycle_station_icon.tscn").instantiate()
		POI.TYPE.WEAPON_FACTORY: return load("res://scenes/ui/POI Icons/weapon_factory_icon.tscn").instantiate()
		
	return null

func get_related_position(initial_position: Vector2, relative_position: Vector2, zoom: float = 1.0) -> Vector2:
	return (initial_position - relative_position) * zoom
