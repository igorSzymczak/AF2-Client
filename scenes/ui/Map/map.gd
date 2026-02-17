extends PanelContainer

@onready var screen: Control = %Screen


var zoom: float = 0.01
var points: Dictionary[int, Node2D] = {}
var icon_scale: float = 0.5

var rendered_types : Array[POI.TYPE] = [
	POI.TYPE.SPAWNER,
	POI.TYPE.PLAYER,
	POI.TYPE.BOSS,
	POI.TYPE.PLANET,
	POI.TYPE.HANGAR,
	POI.TYPE.SUN
]

func _ready():
	for poi: POI in MapManager.pois:
		create_point(poi)
	
	MapManager.poi_created.connect(create_point)
	MapManager.poi_rotation_updated.connect(update_point_rotation)
	MapManager.poi_visibility_updated.connect(update_point_visibility)
	MapManager.poi_label_updated.connect(update_point_label)
	MapManager.poi_removed.connect(remove_point)

func _process(_delta: float) -> void:
	for poi: POI in MapManager.pois:
		update_point_position(poi.id, poi.position)
	
	if Input.is_action_just_pressed("Map") and g.can_perform_actions and !g.me.landed_structure:
		visible = !visible

func create_point(poi: POI) -> void:
	if !rendered_types.has(poi.type):
		return
	
	var point: Node2D = MapManager.create_poi_icon(poi.type)
	point.scale *= icon_scale
	var relative_position: Vector2 = Vector2.ZERO
	if g.me: relative_position = g.me.global_position
	
	point.position = poi.get_related_position(zoom, relative_position)
	
	var label: Label = Label.new()
	label.text = poi.label
	point.add_child(label)
	label.add_theme_font_size_override("font_size", 22)
	label.custom_minimum_size = Vector2(200.0, 0.0)
	label.position = Vector2(-100, 10)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
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

func update_point_label(id: int, value: String) -> void:
	if points.has(id):
		var point: Node2D = points[id]
		var label: Label = point.get_child(1)
		if label:
			label.text = value
			label.position = Vector2(-100, 10)


func remove_point(id: int) -> void:
	if points.has(id):
		var point: Node2D = points[id]
		point.queue_free()
		points.erase(id)
