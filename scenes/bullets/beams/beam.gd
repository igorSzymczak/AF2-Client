class_name Beam extends Node2D

var gid: int
var beam_type: WeaponManager.BeamType
var props := PropertyContainer.new(g.BEAM_PROPERTY_SCHEMA)
var distance: float = 1.0

@export var point_amount: int = 10

func _ready() -> void:
	props.property_changed.connect(_on_property_changed)
	#print("Beam ready!")
	server_position = global_position
	server_rotation = rotation
	_on_ready()

func _on_ready() -> void:
	pass

func _on_property_changed(prop: g.BeamProperty, value: Variant) -> void:
	match prop:
		g.BeamProperty.GID:
			gid = value
		g.BeamProperty.BEAM_TYPE:
			beam_type = value
		g.BeamProperty.GLOBAL_POSITION:
			server_position = value
		g.BeamProperty.ANGLE:
			server_rotation = value
		g.BeamProperty.DISTANCE:
			distance = value
			create_beam()

func _process(delta: float) -> void:
	if !g.Beams.has(gid):
		_handle_death()
	
	interpolate_data(delta)

var server_position: Vector2 = Vector2.ZERO
var server_rotation: float = 0.0
func interpolate_data(delta: float) -> void:
	var factor: float = delta * 20.0
	#print("delta = ", delta, ", a factor = ", factor)
	
	global_position = global_position.lerp(server_position, factor)
	rotation = lerp_angle(rotation, server_rotation, factor)

@export var base_line: Line2D
func create_beam() -> void:
	var mid_distance: float = distance / float(point_amount)
	base_line.clear_points()
	base_line.add_point(Vector2(0.0, 0.0))
	base_line.add_point(Vector2(mid_distance / 10.0, 0.0))
	var i: int = 1
	while base_line.points.size() < point_amount:
		var point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
		base_line.add_point(point_position)
		i+=1
	
	var end_point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
	base_line.add_point(end_point_position - Vector2(mid_distance / 10.0, 0.0))
	base_line.add_point(end_point_position)

func _handle_death() -> void:
	
	queue_free()
