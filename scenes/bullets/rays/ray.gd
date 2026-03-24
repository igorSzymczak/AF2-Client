class_name Ray extends Node2D

var gid: int
var ray_type: WeaponManager.RayType
var props := PropertyContainer.new(g.RAY_PROPERTY_SCHEMA)
@export var gradient_lines_additional_distance: float = 100.0
@export var distance: float = 1.0
@export var radius: float = 3.0 : set = set_radius
@export var time_to_live: float = 1.0

@export var is_local: bool = false
@export var point_amount: int = 10
@export var show_editor_version: bool = false

func _ready() -> void:
	if show_editor_version:
		return
	props.property_changed.connect(_on_property_changed)
	#print("Beam ready!")
	server_position = global_position
	server_rotation = rotation
	create_beam()
	_on_ready()

func _on_ready() -> void:
	pass

func _on_property_changed(prop: g.RayProperty, value: Variant) -> void:
	match prop:
		g.RayProperty.GID:
			gid = value
		g.RayProperty.RAY_TYPE:
			ray_type = value
		g.RayProperty.GLOBAL_POSITION:
			server_position = value
		g.RayProperty.ROTATION:
			server_rotation = value
		g.RayProperty.DISTANCE:
			distance = value
			create_beam()
		g.RayProperty.RADIUS:
			radius = value
		g.RayProperty.TIME_TO_LIVE:
			time_to_live = value
		

func _process(delta: float) -> void:
	if !g.Rays.has(gid) and !is_local:
		_handle_death()
	
	interpolate_data(delta)

var server_position: Vector2 = Vector2.ZERO
var server_rotation: float = 0.0
func interpolate_data(delta: float) -> void:
	if is_local:
		return
	
	var factor: float = delta * 20.0
	
	global_position = global_position.lerp(server_position, factor)
	rotation = lerp_angle(rotation, server_rotation, factor)

@export var base_line: Line2D ## This one will have base radius set
@export var lines: Array[Line2D]
func create_beam() -> void:
	for line in lines:
		var mod_distance: float = distance
		if line != base_line:
			mod_distance += gradient_lines_additional_distance
		
		var mid_distance: float = mod_distance / float(point_amount)
		line.clear_points()
		line.add_point(Vector2(0.0, 0.0))
		line.add_point(Vector2(mid_distance / 10.0, 0.0))
		var i: int = 1
		while line.points.size() <= point_amount:
			var point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
			line.add_point(point_position)
			i+=1
		
		var end_point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
		line.add_point(end_point_position - Vector2(mid_distance / 10.0, 0.0))
		line.add_point(end_point_position)

func set_radius(value: float) -> void:
	if !base_line:
		return
	radius = value
	base_line.set_width(radius)
	#print("Setting width / radius to ", value)

func _handle_death() -> void:
	
	queue_free()
