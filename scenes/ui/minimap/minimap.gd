extends BoxContainer

var zoom: float = 0.02
var points: Dictionary[int, Node2D] = {}

var coords_scale: float = 100.0

@onready var screen = %Screen
@onready var label_x: Label = %PositionX
@onready var label_y: Label = %PositionY


func _ready():
	for poi: POI in MapManager.pois:
		create_point(poi)
	
	MapManager.poi_created.connect(create_point)
	MapManager.poi_rotation_updated.connect(update_point_rotation)
	MapManager.poi_visibility_updated.connect(update_point_visibility)
	MapManager.poi_removed.connect(remove_point)

func _process(_delta: float) -> void:
	if !g.me:
		return
	
	label_x.text = str(roundi(g.me.global_position.x / coords_scale))
	label_y.text = str(roundi(g.me.global_position.y / coords_scale))
	
	for poi: POI in MapManager.pois:
		if !is_instance_valid(poi):
			MapManager.pois.erase(poi)
			if points.has(poi.id): points.erase(poi.id)
			return
		
		update_point_position(poi.id, poi.position)

func create_point(poi: POI) -> void:
	var point: Node2D = MapManager.create_poi_icon(poi.type)
	var relative_position: Vector2 = Vector2.ZERO
	if g.me: relative_position = g.me.global_position
	
	point.position = poi.get_related_position(zoom, relative_position)
	
	screen.add_child(point)
	points[poi.id] = point

func update_point_position(id: int, value: Vector2) -> void:
	if points.has(id):
		var relative_position: Vector2 = Vector2.ZERO
		if g.me: relative_position = g.me.global_position
		
		var point: Node2D = points[id]
		point.position = MapManager.get_related_position(value, relative_position, zoom)

func update_point_rotation(id: int, value: float) -> void:
	if points.has(id):
		var point: Node2D = points[id]
		point.rotation = value

func update_point_visibility(id: int, value: bool) -> void:
	if points.has(id):
		var point: Node2D = points[id]
		point.visible = value

func remove_point(id: int) -> void:
	if points.has(id):
		var point: Node2D = points[id]
		point.queue_free()
		points.erase(id)
