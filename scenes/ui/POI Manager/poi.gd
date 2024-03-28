extends Node
class_name POI

var pos
var display_name
var type
var poi_owner

func _init(global_position: Vector2, poi_name: String, poi_type: String, poi_creator):
	pos = global_position
	display_name = poi_name
	type = poi_type
	poi_owner = poi_creator
