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

var _Weapons: Dictionary[Type, PackedScene] = {
	Type.CLUSTER_MISSILES: load("res://scenes/weapons/ClusterMissiles/cluster_missiles.tscn"),
	Type.GATLING_LASER: load("res://scenes/weapons/GatlingLaser/gatling_laser.tscn"),
	Type.ACID_BLASTER: load("res://scenes/weapons/AcidBlaster/acid_blaster.tscn"),
	Type.RAILGUN: load("res://scenes/weapons/Railgun/railgun.tscn"),
	Type.ROCKET_LAUNCHER: load("res://scenes/weapons/RocketLauncher/rocket_launcher.tscn"),
	Type.PLASMA_GUN: load("res://scenes/weapons/PlasmaGun/plasma_gun.tscn"),
	Type.PIERCING_GUN: load("res://scenes/weapons/PiercingGun/piercing_gun.tscn"),
	Type.SPAWNER_LASER: load("res://scenes/weapons/SpawnerLaser/spawner_laser_gun.tscn"),
	Type.SHOCKWAVE_GENERATOR: load("res://scenes/weapons/ShockwaveGenerator/shockwave_generator.tscn"),
	Type.ENERGY_NOVA: load("res://scenes/weapons/Energy Nova/energy_nova.tscn"),
	Type.ENERGY_BLAST: load("res://scenes/weapons/EnergyBlast/energy_blast.tscn"),
}

func get_type(weapon: Weapon) -> Type:
	return weapon.weapon_type

func get_weapon(type: Type) -> Weapon:
	return _Weapons[type].instantiate()

func get_weapon_scene(type: Type) -> PackedScene:
	return _Weapons[type]

enum BulletType {
	DEFAULT,
	DEFAULT_HOMING,
	MISSILE,
	LASER,
	ACID,
	RAILGUN_BULLET,
	ROCKET,
	PLASMA,
	PIERCING_BULLET,
	SPAWNER_LASER,
	ENERGY_BLAST_PROJECTILE,
}

var _Bullets: Dictionary[BulletType, PackedScene] = {
	BulletType.DEFAULT: load("res://scenes/bullets/bullet_types/bullet.tscn"),
	BulletType.DEFAULT_HOMING: load("res://scenes/bullets/bullet_types/bullet_homing.tscn"),
	BulletType.MISSILE: load("res://scenes/bullets/bullets/ClusterMissiles/missile.tscn"),
	BulletType.LASER: load("res://scenes/bullets/bullets/GatlingLaser/gatling_laser.tscn"),
	BulletType.ACID: load("res://scenes/bullets/bullets/AcidBlaster/acid.tscn"),
	BulletType.RAILGUN_BULLET: load("res://scenes/bullets/bullets/Railgun/railgun_bullet.tscn"),
	BulletType.ROCKET: load("res://scenes/bullets/bullets/RocketLauncher/rocket.tscn"),
	BulletType.PLASMA: load("res://scenes/bullets/bullets/PlasmaGun/plasma.tscn"),
	BulletType.PIERCING_BULLET: load("res://scenes/bullets/bullets/PiercingGun/piercing_bullet.tscn"),
	BulletType.SPAWNER_LASER: load("res://scenes/bullets/bullets/SpawnerLaser/spawner_laser.tscn"),
	BulletType.ENERGY_BLAST_PROJECTILE: load("res://scenes/bullets/bullets/EnergyBlast/energy_blast_projectile.tscn")
}

func get_bullet_type(bullet: Bullet) -> BulletType:
	return bullet.bullet_type

func get_bullet(bullet_type: BulletType) -> Bullet:
	return _Bullets[bullet_type].instantiate()

func get_bullet_scene(bullet_type: BulletType) -> PackedScene:
	return _Bullets[bullet_type]

enum ShockwaveType {
	SHOCKWAVE,
	NOVA,
	ENERGY_BLAST_EXPLOSION
}

var _Shockwaves: Dictionary[ShockwaveType, PackedScene] = {
	ShockwaveType.SHOCKWAVE: load("res://scenes/bullets/shockwaves/shockwave/shockwave.tscn"),
	ShockwaveType.NOVA: load("res://scenes/bullets/shockwaves/energy nova/nova.tscn"),
	ShockwaveType.ENERGY_BLAST_EXPLOSION: load("res://scenes/bullets/shockwaves/EnergyBlast/energy_blast_explosion.tscn")
}

func get_shockwave_type(shockwave: ShockWave) -> ShockwaveType:
	return shockwave.shockwave_type

func get_shockwave(shockwave_type: ShockwaveType) -> ShockWave:
	return _Shockwaves[shockwave_type].instantiate()

func get_shockwave_scene(shockwave_type: ShockwaveType) -> PackedScene:
	return _Shockwaves[shockwave_type]
