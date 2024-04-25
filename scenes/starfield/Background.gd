extends Sprite2D

var elapsed_time := 0
var player: Player

var default_zoom := 0.5
var zoom_scale: float = default_zoom
func _set_zoom(new_scale: float) -> void:
	new_scale = default_zoom + (default_zoom - new_scale)
	zoom_scale = new_scale

var camera_offset := Vector2.ZERO
func _set_offset(new_offset: Vector2) -> void:
	camera_offset = new_offset

func _setup_main_player(new_main_player) -> void:
	player = new_main_player

func _ready() -> void:
	GlobalSignals.connect("camera_zoom", _set_zoom)
	GlobalSignals.connect("camera_offset", _set_offset)
	GlobalSignals.connect("give_main_player", _setup_main_player)

func _process(delta):
	if is_instance_valid(player) and visible:
		position = player.position
		material.set_shader_parameter("time", elapsed_time)
		material.set_shader_parameter("mouse", player.position/10000.0 * zoom_scale + camera_offset/10000)
		material.set_shader_parameter("zoom", zoom_scale)
		elapsed_time += delta
