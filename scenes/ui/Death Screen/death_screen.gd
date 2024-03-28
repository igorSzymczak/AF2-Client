extends Control

@onready var you_are_dead = $PanelContainer/Top/MarginContainer/VBoxContainer/YouAreDead
@onready var respawn_timer = $PanelContainer/Top/MarginContainer/VBoxContainer/RespawnTimer
@onready var killed_by = $PanelContainer/Bottom/MarginContainer/VBoxContainer/KilledBy
@onready var killer_label = $PanelContainer/Bottom/MarginContainer/VBoxContainer/Killer

func set_args(args: Dictionary):
	if args.has("respawn_time"):
		var respawn_time = args["respawn_time"]
		_set_respawn_timer(respawn_time)
	
	if args.has("killer"):
		var killer = args["killer"]
		_set_killer_label(killer)
		

func _set_respawn_timer(respawn_time: int):
	respawn_timer.set_text("Respawn in " + str(respawn_time) + "...")

func _set_killer_label(killer: String):
	killer_label.set_text(killer)
