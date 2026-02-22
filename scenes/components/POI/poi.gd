class_name POI extends Node

enum TYPE {
	PLAYER,
	SPAWNER,
	ENEMY,
	ALLY,
	BOSS,
	PLANET,
	HANGAR,
	SUN,
	ITEM,
	RECYCLE_STATION,
	WEAPON_FACTORY
}

var id: int
@export var type: TYPE
var position: Vector2 = Vector2.ZERO
var visible: bool = true : set = change_visible
var rotation: float = 0.0
@export var should_update_rotation: bool = false
@export var label: String : set = set_label
@onready var parent: Node2D = get_parent() as Node2D

func _ready() -> void:
	await parent.ready
	id = parent.get_instance_id()
	position = parent.global_position
	MapManager.pois.append(self)
	MapManager.poi_created.emit(self)

func _process(_delta: float) -> void:
	if position != parent.global_position:
		position = parent.global_position
		position_changed.emit(position)
		MapManager.poi_position_updated.emit(id, position)
	
	if should_update_rotation and rotation != parent.rotation:
		rotation = parent.rotation
		rotation_changed.emit(rotation)
		MapManager.poi_rotation_updated.emit(id, rotation)

func get_related_position(scale: float, relative_position: Vector2 = Vector2.ZERO) -> Vector2:
	return (position - relative_position) * scale

func change_visible(value: bool) -> void:
	visible = value
	MapManager.poi_visibility_updated.emit(id, visible)

func set_label(value: String) -> void:
	label = value
	MapManager.poi_label_updated.emit(id, label)

func remove():
	MapManager.poi_removed.emit(id)
	MapManager.pois.erase(self)

signal position_changed(value: Vector2)
signal rotation_changed(value: float)
signal visibility_changed(value: bool)
