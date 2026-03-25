extends Node

enum StatType {
	DMG = 0,
	RPS = 1,
	POWER = 2,
	RANGE = 3,
	UPGRADES_ARRAY = 4
}

enum WeaponDataType {
	MIN = 0,
	MAX = 1,
	POINTS_MIN = 2,
	POINTS_MAX = 3,
}

var weapons_data: Dictionary[Type, Array] = {}

@rpc("authority", "call_remote", "reliable")
func send_weapons_data(data: Dictionary[Type, Array]) -> void:
	_handle_weapons_data_sent(data)

func _handle_weapons_data_sent(data: Dictionary[Type, Array]) -> void:
	weapons_data = data

func get_weapon_data(weapon_type: Type, stat_type: StatType, data_type: WeaponDataType) -> float:
	if stat_type == StatType.UPGRADES_ARRAY:
		return 0
	return weapons_data[weapon_type][stat_type][data_type]

func get_weapon_upgrades_info(weapon_type: Type, lvl: int) -> PackedStringArray:
	if lvl <= 0 or lvl > 3: return []
	var base_upgrades: Dictionary = weapons_data[weapon_type][StatType.UPGRADES_ARRAY][0]
	var lvl_upgrades: Dictionary = weapons_data[weapon_type][StatType.UPGRADES_ARRAY][lvl]
	
	var upgrades_info: PackedStringArray = []
	for prop: Weapon.Property in lvl_upgrades:
		var upgraded_value: Variant = lvl_upgrades[prop]
		var base_value: Variant = base_upgrades[prop]
		if upgraded_value is Dictionary:
			continue
		
		var difference: float = 0
		var sign_space: String = "+ "
		if upgraded_value is float or upgraded_value is int:
			difference = upgraded_value - base_upgrades[prop]
			sign_space = "- " if difference < 0 else "+ "
		
		var percent_difference: float = 0.0
		if base_value != 0:
			percent_difference = (difference / base_value) * 100.0
		
		var info: String = ""
		match prop:
			Weapon.Property.DAMAGE: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% base damage"
			Weapon.Property.SHOOT_DELAY: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% shoot delay"
			Weapon.Property.BULLET_SPREAD: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% bullet spread"
			Weapon.Property.BULLET_AMOUNT: info = sign_space + Functions.shorten_number(abs(difference)) + " bullets shot"
			Weapon.Property.BULLET_AMOUNT_RNG: info = "randomly shoot up to " + Functions.shorten_number(upgraded_value) + " additional bullets"
			Weapon.Property.POWER_USAGE_PER_SHOOT: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% used power"
			Weapon.Property.WEAPON_OUTPUTS: info = sign_space + Functions.shorten_number(abs(difference)) + " weapon outputs"
			Weapon.Property.WEAPON_OUTPUTS_DISTANCE: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% outputs distance"
			Weapon.Property.BULLET_SPEED: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% bullet speed"
			Weapon.Property.BULLET_SPEED_RNG: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% random bullet speed"
			Weapon.Property.BULLET_LIFE_TIME: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% bullet life time"
			Weapon.Property.BULLET_LIFE_TIME_RNG: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% bullet random life time"
			Weapon.Property.BULLET_FALL: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% bullet fatigue"
			Weapon.Property.BULLET_PIERCING_AMOUNT: info = "pierce up to " + Functions.shorten_number(abs(upgraded_value)) + " targets"
			Weapon.Property.BULLET_AOE_RADIUS: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% AOE radius"
			#Weapon.Property.BULLET_OTHER_ARGS: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% "
			Weapon.Property.SHOCKWAVE_ANGLE: info = Functions.shorten_number(abs(upgraded_value / PI * 180.0)) + "degree angle"
			Weapon.Property.SHOCKWAVE_SCALE_SPEED: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% grow speed"
			Weapon.Property.SHOCKWAVE_TIME_TO_VANISH_SECONDS: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% life time"
			Weapon.Property.HOMING_TURN_SPEED: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% homing speed"
			Weapon.Property.HOMING_GUIDANCE_RADIUS: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% homing distance"
			Weapon.Property.HOMING_MAX_SPEED_RATIO: info = sign_space + Functions.shorten_number(abs(percent_difference)) + "% max speed"
		
		upgrades_info.append(info)
	return upgrades_info

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
	TORPEDOES,
	BEAM_WEAPON,
	STAR_MELTER,
	RAY_WEAPON,
	DEATH_AREA_CREATOR,
	OVERSEER_DRONE_RAY_WEAPON,
	OVERSEER_RAY_WEAPON,
	OVERSEER_LASER_GUN,
	OVERSEER_DEATH_AREA,
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
	Type.TORPEDOES: load("res://scenes/weapons/Torpedoes/torpedoes.tscn"),
	Type.BEAM_WEAPON: load("res://scenes/weapons/BeamWeapon/beam_weapon.tscn"),
	Type.STAR_MELTER: load("res://scenes/weapons/StarMelter/star_melter.tscn"),
	Type.RAY_WEAPON: load("res://scenes/weapons/RayWeapon/ray_weapon.tscn"),
	Type.DEATH_AREA_CREATOR: load("res://scenes/weapons/DeathAreaCreator/death_area_creator.tscn"),
	Type.OVERSEER_DRONE_RAY_WEAPON: load("res://scenes/weapons/OverseerDroneRay/overseer_drone_ray_weapon.tscn"),
	Type.OVERSEER_RAY_WEAPON: load("res://scenes/weapons/OverseerRay/overseer_ray_weapon.tscn"),
	Type.OVERSEER_LASER_GUN: load("res://scenes/weapons/OverseerLaserGun/overseer_laser_gun.tscn"),
	Type.OVERSEER_DEATH_AREA: load("res://scenes/weapons/OverseerDeathArea/overseer_death_area_weapon.tscn")
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
	TORPEDO,
	OVERSEER_LASER,
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
	BulletType.ENERGY_BLAST_PROJECTILE: load("res://scenes/bullets/bullets/EnergyBlast/energy_blast_projectile.tscn"),
	BulletType.TORPEDO: load("res://scenes/bullets/bullets/Torpedoes/torpedo.tscn"),
	BulletType.OVERSEER_LASER: load("res://scenes/weapons/OverseerLaserGun/overseer_laser.tscn")
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



enum BeamType {
	BEAM,
	STAR_MELTER_BEAM,
	
}

var _Beams: Dictionary[BeamType, PackedScene] = {
	BeamType.BEAM: load("res://scenes/bullets/beams/beam.tscn"),
	BeamType.STAR_MELTER_BEAM: load("res://scenes/weapons/StarMelter/star_melter_beam.tscn"),
	
}

func get_beam_type(beam: Beam) -> BeamType:
	return beam.beam_type

func get_beam(beam_type: BeamType) -> Beam:
	return _Beams[beam_type].instantiate()

func get_beam_scene(beam_type: BeamType) -> PackedScene:
	return _Beams[beam_type]



enum RayType {
	RAY,
	OVERSEER_DRONE_RAY,
	OVERSEER_RAY,
	
}

var _Rays: Dictionary[RayType, PackedScene] = {
	RayType.RAY: load("res://scenes/bullets/rays/ray.tscn"),
	RayType.OVERSEER_DRONE_RAY: load("res://scenes/weapons/OverseerDroneRay/overseer_drone_ray.tscn"),
	RayType.OVERSEER_RAY: load("res://scenes/weapons/OverseerRay/overseer_ray.tscn")
}

func get_ray_type(ray: Ray) -> RayType:
	return ray.ray_type

func get_ray(ray_type: RayType) -> Ray:
	return _Rays[ray_type].instantiate()

func get_ray_scene(ray_type: RayType) -> PackedScene:
	return _Rays[ray_type]

enum DeathAreaType {
	DEATH_AREA,
	OVERSEER_DEATH_AREA,
}

var _DeathAreas: Dictionary[DeathAreaType, PackedScene] = {
	DeathAreaType.DEATH_AREA: load("res://scenes/bullets/death_areas/death_area.tscn"),
	DeathAreaType.OVERSEER_DEATH_AREA: load("res://scenes/weapons/OverseerDeathArea/overseer_death_area.tscn")
	
}

func get_death_area_type(death_area: DeathArea) -> DeathAreaType:
	return death_area.death_area_type

func get_death_area(death_area_type: DeathAreaType) -> DeathArea:
	return _DeathAreas[death_area_type].instantiate()

func get_death_area_scene(death_area_type: DeathAreaType) -> PackedScene:
	return _DeathAreas[death_area_type]
