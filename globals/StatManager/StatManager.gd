extends Node

var my_stats: Stats = Stats.new()

func dictionary_to_stats(stats: Dictionary[int, float]):
	for id in stats.keys():
		my_stats.set_stat_value(id, stats[id])

@rpc("call_remote", "authority", "reliable")
func update_player_stats(stats: Dictionary[int, float]):
	_handle_update_player_stats(stats)

@rpc("call_remote", "authority", "reliable")
func update_player_stat(stat: int, value: float):
	_handle_update_player_stat(stat, value)

@rpc("call_remote", "authority", "reliable")
func _update_entity_stats(entity_type: int, gid: int, stats: Dictionary[int, float]):
	_handle_update_entity_stats(entity_type, gid, stats)

@rpc("call_remote", "authority", "reliable")
func _update_entity_stat(entity_type: int, gid: int, stat: int, value: float):
	_handle_update_entity_stat(entity_type, gid, stat, value)

func _handle_update_entity_stats(entity_type: int, gid: int, stats: Dictionary[int, float]):
	match entity_type as g.ENTITY_TYPE:
		g.ENTITY_TYPE.PLAYER:	g.update_player_stats(gid, stats as Dictionary[Stats.TYPE, float])
		g.ENTITY_TYPE.ENEMY:	g.update_enemy_stats(gid, stats as Dictionary[Stats.TYPE, float])
		g.ENTITY_TYPE.SPAWNER:	g.update_spawner_stats(gid, stats as Dictionary[Stats.TYPE, float])
		g.ENTITY_TYPE.TURRET:	g.update_turret_stats(gid, stats as Dictionary[Stats.TYPE, float])
		g.ENTITY_TYPE.BOSS:		g.update_boss_stats(gid, stats as Dictionary[Stats.TYPE, float])

func _handle_update_entity_stat(entity_type: int, gid: int, stat: int, value: float):
	match entity_type as g.ENTITY_TYPE:
		g.ENTITY_TYPE.PLAYER:	g.update_player_stat(gid, stat as Stats.TYPE, value)
		g.ENTITY_TYPE.ENEMY:	g.update_enemy_stat(gid, stat as Stats.TYPE, value)
		g.ENTITY_TYPE.SPAWNER:	g.update_spawner_stat(gid, stat as Stats.TYPE, value)
		g.ENTITY_TYPE.TURRET:	g.update_turret_stat(gid, stat as Stats.TYPE, value)
		g.ENTITY_TYPE.BOSS:		g.update_boss_stat(gid, stat as Stats.TYPE, value)

func _handle_update_player_stat(stat: int, value: float) -> void:
	var stat_type: Stats.TYPE = stat as Stats.TYPE
	my_stats.set_stat_value(stat_type, value)
	
func _handle_update_player_stats(stats: Dictionary[int, float]) -> void:
	my_stats = dictionary_to_stats(stats)
