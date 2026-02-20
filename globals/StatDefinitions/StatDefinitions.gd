extends Node

const DEFINITIONS: Dictionary[Stats.TYPE, Dictionary] = {
	Stats.TYPE.MAX_SHIELD: {
		"base": 100.0,
		"min": 1.0,
		"max": 1_000_000.0
	},
	Stats.TYPE.SHIELD_REGEN: {
		"base": 5.0,
		"min": 0.0,
		"max": 10_000.0
	},
	Stats.TYPE.MAX_HEALTH: {
		"base": 100.0,
		"min": 1.0,
		"max": 1_000_000.0
	},
	Stats.TYPE.ARMOR: {
		"base": 5.0,
		"min": 1.0,
		"max": 10_000.0
	},

	Stats.TYPE.DAMAGE_KINETIC: {
		"base": 0.0,
		"min": 0.0,
		"max": 100_000.0
	},
	Stats.TYPE.DAMAGE_ENERGY: {
		"base": 8.0,
		"min": 0.0,
		"max": 100_000.0
	},
	Stats.TYPE.DAMAGE_CORROSIVE: {
		"base": 6.0,
		"min": 0.0,
		"max": 100_000.0
	},
	
	Stats.TYPE.RESISTANCE_KINETIC: {
		"base": 0.0,
		"min": -10.0,
		"max": 10.0,
	},
	Stats.TYPE.RESISTANCE_ENERGY: {
		"base": 0.0,
		"min": -10.0,
		"max": 10.0,
	},
	Stats.TYPE.RESISTANCE_CORROSIVE: {
		"base": 0.0,
		"min": -10.0,
		"max": 10.0,
	},

	Stats.TYPE.MAX_POWER: {
		"base": 100.0,
		"min": 1.0,
		"max": 1_000.0
	},
	Stats.TYPE.POWER_REGEN: {
		"base": 5.0,
		"min": 0.1,
		"max": 100.0
	},
	Stats.TYPE.SPEED: {
		"base": 300.0,
		"min": 0.0,
		"max": 5_000.0
	},
	Stats.TYPE.TURN_SPEED: {
		"base": 3.0,
		"min": 0.1,
		"max": 10.0
	},

	Stats.TYPE.SPEED_BOOST_DELAY: {
		"base": 3.0,
		"min": 0.0,
		"max": 10.0
	},
	Stats.TYPE.SPEED_BOOST_DURATION: {
		"base": 1.5,
		"min": 0.5,
		"max": 3.0
	},
	Stats.TYPE.SPEED_BOOST_STRENGTH: {
		"base": 1.5,
		"min": 0.1,
		"max": 20.0
	},
	Stats.TYPE.SPEED_BOOST_TURN_SPEED: {
		"base": 0.0,
		"min": 0.0,
		"max": 1.0
	},
}

const STATS_AFFECTED_BY_LVL: Array[Stats.TYPE] = [
	Stats.TYPE.MAX_SHIELD,
	Stats.TYPE.MAX_HEALTH,
	Stats.TYPE.SHIELD_REGEN,
	Stats.TYPE.ARMOR,
	Stats.TYPE.DAMAGE_KINETIC,
	Stats.TYPE.DAMAGE_ENERGY,
	Stats.TYPE.DAMAGE_CORROSIVE,
	Stats.TYPE.MAX_SHIELD
]

func get_base(stat_type: Stats.TYPE) -> float:
	return DEFINITIONS[stat_type]["base"]

func get_min(stat_type: Stats.TYPE) -> float:
	return DEFINITIONS[stat_type]["min"]

func get_max(stat_type: Stats.TYPE) -> float:
	return DEFINITIONS[stat_type]["max"]
