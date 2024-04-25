extends Node

var exp: int
var goal_exp: int 
var lvl: int

@rpc("authority", "call_remote", "reliable")
func _set_exp(new_exp: int):
	_handle_set_exp(new_exp)

@rpc("authority", "call_remote", "reliable")
func _set_goal_exp(new_exp: int):
	_handle_set_goal_exp(new_exp)

@rpc("authority", "call_remote", "reliable")
func _add_exp(exp_addition: int):
	_handle_add_exp(exp_addition)

@rpc("authority", "call_remote", "reliable")
func _set_lvl(new_lvl: int):
	_handle_set_lvl(new_lvl)

signal exp_set(new_exp: int)
func _handle_set_exp(new_exp: int):
	exp_set.emit(new_exp)
	exp = new_exp
	
signal goal_exp_set(new_exp: int)
func _handle_set_goal_exp(new_goal_exp: int):
	goal_exp_set.emit(new_goal_exp)
	goal_exp = new_goal_exp

signal exp_added(exp_addition: int)
func _handle_add_exp(exp_addition: int): 
	exp_added.emit(exp_addition)

signal lvl_set(new_lvl: int)
func _handle_set_lvl(new_lvl: int):
	lvl_set.emit(new_lvl)
	lvl = new_lvl
