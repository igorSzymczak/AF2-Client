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

const _Weapons: Dictionary[Type, PackedScene] = {
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

const _Bullets: Dictionary[BulletType, PackedScene] = {
	BulletType.DEFAULT: preload("res://scenes/bullets/bullet_types/bullet.tscn"),
	BulletType.DEFAULT_HOMING: preload("res://scenes/bullets/bullet_types/bullet_homing.tscn"),
	BulletType.MISSILE: preload("res://scenes/bullets/bullets/ClusterMissiles/missile.tscn"),
	BulletType.LASER: preload("res://scenes/bullets/bullets/GatlingLaser/gatling_laser.tscn"),
	BulletType.ACID: preload("res://scenes/bullets/bullets/AcidBlaster/acid.tscn"),
	BulletType.RAILGUN_BULLET: preload("res://scenes/bullets/bullets/Railgun/railgun_bullet.tscn"),
	BulletType.ROCKET: preload("res://scenes/bullets/bullets/RocketLauncher/rocket.tscn"),
	BulletType.PLASMA: preload("res://scenes/bullets/bullets/PlasmaGun/plasma.tscn"),
	BulletType.PIERCING_BULLET: preload("res://scenes/bullets/bullets/PiercingGun/piercing_bullet.tscn"),
	BulletType.SPAWNER_LASER: preload("res://scenes/bullets/bullets/SpawnerLaser/spawner_laser.tscn"),
	BulletType.ENERGY_BLAST_PROJECTILE: preload("res://scenes/bullets/bullets/EnergyBlast/energy_blast_projectile.tscn")
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

const _Shockwaves: Dictionary[ShockwaveType, PackedScene] = {
	ShockwaveType.SHOCKWAVE: preload("res://scenes/bullets/shockwaves/shockwave/shockwave.tscn"),
	ShockwaveType.NOVA: preload("res://scenes/bullets/shockwaves/energy nova/nova.tscn"),
	ShockwaveType.ENERGY_BLAST_EXPLOSION: preload("res://scenes/bullets/shockwaves/EnergyBlast/energy_blast_explosion.tscn")
}

func get_shockwave_type(shockwave: ShockWave) -> ShockwaveType:
	return shockwave.shockwave_type

func get_shockwave(shockwave_type: ShockwaveType) -> ShockWave:
	return _Shockwaves[shockwave_type].instantiate()

func get_shockwave_scene(shockwave_type: ShockwaveType) -> PackedScene:
	return _Shockwaves[shockwave_type]
