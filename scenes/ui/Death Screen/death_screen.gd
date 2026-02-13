extends Control

@onready var you_are_dead = $PanelContainer/Top/MarginContainer/VBoxContainer/YouAreDead
@onready var respawn_timer = $PanelContainer/Top/MarginContainer/VBoxContainer/RespawnTimer
@onready var killed_by = $PanelContainer/Bottom/MarginContainer/VBoxContainer/KilledBy
@onready var killer_label = $PanelContainer/Bottom/MarginContainer/VBoxContainer/Killer

var time_to_respawn_sec: float = 0.0

func _ready() -> void:
	await AuthManager.joined
	g.me.props.property_changed.connect(_on_player_property_changed)

func _process(delta: float) -> void:
	if time_to_respawn_sec <= 0.0:
		return
	
	time_to_respawn_sec -= delta
	_set_respawn_timer()
	

func _on_player_property_changed(prop: int, value: Variant):
	if prop != g.PlayerProperty.DEATH_ARGS:
		return
	
	var death_args: Dictionary = value
	
	if death_args.has("respawn_time"):
		time_to_respawn_sec = death_args["respawn_time"]
		_set_respawn_timer()
	
	if death_args.has("killer"):
		var killer = death_args["killer"]
		_set_killer_label(killer)
		

func _set_respawn_timer():
	respawn_timer.set_text("Respawn in " + str(int(ceil(time_to_respawn_sec))) + "...")

func _set_killer_label(killer: String):
	killer_label.set_text(killer)
