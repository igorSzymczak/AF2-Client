extends Node

const player_scene: PackedScene = preload("res://scenes/entities/Player/player.tscn")

enum ActorType {
	ZLATTE,
	ELITE_LAUNCHER
}

var Actors: Dictionary[ActorType, PackedScene] = {
	ActorType.ZLATTE : load("res://scenes/entities/Actor/Zlatte/Zlatte.tscn"),
	ActorType.ELITE_LAUNCHER: load("res://scenes/entities/Actor/EliteLauncher/Launcher.tscn")
}

func get_actor_type(actor: Actor) -> ActorType:
	return actor.actor_type

func get_actor(actor_type: ActorType) -> Actor:
	return Actors[actor_type].instantiate()

func get_actor_scene(actor_type: ActorType) -> PackedScene:
	return Actors[actor_type]


enum TurretType {
	DEFAULT,
}

var Turrets: Dictionary[TurretType, PackedScene] = {
	TurretType.DEFAULT : load("res://scenes/objects/Spawners/Turrets/turret.tscn")
}

func get_turret_type(turret: Turret) -> TurretType:
	return turret.turret_type

func get_turret(turret_type: TurretType) -> Turret:
	return Turrets[turret_type].instantiate()

func get_turret_scene(turret_type: TurretType) -> PackedScene:
	return Turrets[turret_type]


enum SpawnerType {
	DEFAULT,
}

var Spawners: Dictionary[SpawnerType, PackedScene] = {
	SpawnerType.DEFAULT : load("res://scenes/objects/Spawners/spawner.tscn")
}

func get_spawner_type(spawner: Spawner) -> SpawnerType:
	return spawner.spawner_type

func get_spawner(spawner_type: SpawnerType) -> Spawner:
	return Spawners[spawner_type].instantiate()

func get_spawner_scene(spawner_type: SpawnerType) -> PackedScene:
	return Spawners[spawner_type]
