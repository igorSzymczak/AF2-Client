extends Node
class_name POI_manager

var POIs: Array[Node] = []
#signal added_poi(poi: POI)
#signal deleted_poi(poi: POI)

func _ready() -> void:
	GlobalSignals.connect("delete_poi", delete_poi)
	POIs = get_tree().get_nodes_in_group("points_of_interest")

func delete_poi(poi) -> void:
	POIs.erase(poi)

func _process(_delta):
	if get_tree().get_nodes_in_group("points_of_interest").size() > POIs.size():
		POIs = get_tree().get_nodes_in_group("points_of_interest")
