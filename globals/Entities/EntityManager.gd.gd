extends Node

enum Type {
	ZLATTE,
	ELITE_LAUNCHER
}

var Enemies: Dictionary[Type, PackedScene] = {
	Type.ZLATTE : preload("res://scenes/entities/Actor/actor.tscn"),
	#Type.ELITE_LAUNCHER: 
}

enum TurretType {
	DEFAULT,
}

var Turrets: Dictionary[TurretType, PackedScene] = {
	TurretType.DEFAULT : preload("res://scenes/objects/Spawners/Turrets/turret.tscn")
}

func get_turret_type(turret: Turret) -> TurretType:
	return turret.turret_type

func get_turret(turret_type: TurretType) -> Turret:
	return Turrets[turret_type].instantiate()

func get_turret_scene(turret_type: TurretType) -> PackedScene:
	return Turrets[turret_type]
