extends Sprite2D

var elapsed_time := 0
var player: Player

var default_zoom := 0.5
var zoom_scale: float = default_zoom

@onready var simple_stars: ColorRect = %SimpleStars

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
	
	g.user_prefs.graphics_changed.connect(_on_graphics_changed)
	_on_graphics_changed(g.user_prefs.graphics)

func _on_graphics_changed(graphics: UserPreferences.Graphics) -> void:
	if graphics == UserPreferences.Graphics.HIGH:
		simple_stars.hide()
		show()
		material.set_shader_parameter("iterations", 4)
		material.set_shader_parameter("volsteps", 4.0)
	elif graphics == UserPreferences.Graphics.MEDIUM:
		simple_stars.hide()
		show()
		material.set_shader_parameter("iterations", 3)
		material.set_shader_parameter("volsteps", 2.0)
	elif graphics == UserPreferences.Graphics.LOW:
		hide()
		simple_stars.show()
		simple_stars.material.set_shader_parameter("layer_count", 3)
	elif graphics == UserPreferences.Graphics.POTATO:
		hide()
		simple_stars.show()
		simple_stars.material.set_shader_parameter("layer_count", 1)
	

func _process(delta):
	if !is_instance_valid(player):
		return
	
	if visible:
		position = player.position
		material.set_shader_parameter("time", elapsed_time)
		material.set_shader_parameter("mouse", player.position/10000.0 + camera_offset/10000)
		material.set_shader_parameter("zoom", zoom_scale * 1.5)
		elapsed_time += delta
	elif simple_stars.visible:
		var final_position: Vector2 = player.position / 5.0 + camera_offset / 5.0
		simple_stars.material.set_shader_parameter("offset", final_position)
		simple_stars.material.set_shader_parameter("zoom", (zoom_scale * 1.5) - 0.3)
