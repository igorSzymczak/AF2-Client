extends Node

enum Type {
	CLUSTER_MISSILES,
	GATLING_LASER,
	ACID_BLASTER,
	RAILGUN,
	ROCKET_LAUNCHER,
	PLASMA_GUN,
	PIERCING_GUN,
	SPAWNER_LASER,
	SHOCKWAVE_GENERATOR,
	ENERGY_NOVA,
	ENERGY_BLAST,
}

var Weapons: Dictionary[Type, PackedScene] = {
	Type.CLUSTER_MISSILES: preload("res://scenes/weapons/ClusterMissiles/cluster_missiles.tscn"),
	Type.GATLING_LASER: preload("res://scenes/weapons/GatlingLaser/gatling_laser.tscn"),
	Type.ACID_BLASTER: preload("res://scenes/weapons/AcidBlaster/acid_blaster.tscn"),
	Type.RAILGUN: preload("res://scenes/weapons/Railgun/railgun.tscn"),
	Type.ROCKET_LAUNCHER: preload("res://scenes/weapons/RocketLauncher/rocket_launcher.tscn"),
	Type.PLASMA_GUN: preload("res://scenes/weapons/PlasmaGun/plasma_gun.tscn"),
	Type.PIERCING_GUN: preload("res://scenes/weapons/PiercingGun/piercing_gun.tscn"),
	Type.SPAWNER_LASER: preload("res://scenes/weapons/SpawnerLaser/spawner_laser_gun.tscn"),
	Type.SHOCKWAVE_GENERATOR: preload("res://scenes/weapons/ShockwaveGenerator/shockwave_generator.tscn"),
	Type.ENERGY_NOVA: preload("res://scenes/weapons/Energy Nova/energy_nova.tscn"),
	Type.ENERGY_BLAST: preload("res://scenes/weapons/EnergyBlast/energy_blast.tscn"),
}

func get_type(weapon: Weapon) -> Type:
	return weapon.weapon_type

func get_weapon(type: Type) -> Weapon:
	return Weapons[type].instantiate()

func get_weapon_scene(type: Type) -> PackedScene:
	return Weapons[type]
