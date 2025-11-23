extends BoxContainer

@onready var player : Player

@export var zoom: float = 10

@onready var poi_manager: POI_manager = $PoiManager
@onready var grid = $Grid
@onready var screen = $Grid/Screen
@onready var dot_enemy = $Grid/Screen/DotEnemy
@onready var dot_planet = $Grid/Screen/DotPlanet
@onready var dot_sun = $Grid/Screen/DotSun
@onready var dot_spawner = $Grid/Screen/DotSpawner
@onready var other_player_arrow = $Grid/Screen/OtherPlayerArrow
@onready var player_arrow = $Grid/Screen/PlayerArrow
@onready var boss_icon = $Grid/Screen/BossIcon
@onready var hangar_icon = $Grid/Screen/HangarIcon

@onready var localization_label = $Grid/PanelContainer/MarginContainer/LocalizationLabel

@onready var icons = {
	"enemy": dot_enemy,
	"spawner": dot_spawner,
	"planet": dot_planet,
	"sun": dot_sun,
	"player": other_player_arrow,
	"boss": boss_icon,
	"hangar": hangar_icon
}

@onready var grid_scale = grid.get_rect().size / 1920 / zoom

var elements: Array[Dictionary] = []

func _ready():
	grid_scale = grid.get_rect().size / (1920 * zoom)
	GlobalSignals.connect("give_main_player", set_player)
	GlobalSignals.connect("setup_poi", create_element)
	GlobalSignals.connect("delete_poi", delete_element_with_poi)

func set_player(emitted_player: Player):
	self.player = emitted_player
	for poi in poi_manager.POIs:
		create_element(poi)

func _process(_delta):
	if !player:
		return
	player = g.me
	
	localization_label.text = str(round(player.global_position.x / 50.0)) + ", " + str(round(player.global_position.y / 50.0))
	rotate_player()
	update_elements()
	
func rotate_player() -> void:
	player_arrow.rotation = player.rotation + PI/2

func delete_element_with_poi(poi_to_remove):
	for i in range(elements.size()):
		var element = elements[i]
		if element.poi == poi_to_remove:
			element.point.queue_free()
			elements.pop_at(i)
			return

func create_element(poi) -> void:
	if (poi.has_method("get_visibility") and poi.get_visibility()) or !poi.has_method("get_visibility"):
		if !is_instance_valid(player):
			player = g.me
		if !player: return
		var minimap_position = (poi.global_position - player.global_position) * grid_scale
		
		var dot: Sprite2D
		var type = poi.poi_type
		
		dot = icons[type].duplicate()
		screen.add_child(dot)
		
		dot.position = minimap_position
		if poi is Player:
			dot.rotation = poi.rotation
		
		var element = {
			"poi" = poi,
			"point" = dot
		}
		elements.append(element)

func update_elements() -> void:
	
	var radar_scale = grid.get_rect().size / 1920 / zoom
	for element in elements:
		var minimap_position = (element.poi.global_position - player.global_position) * radar_scale
		
		element.point.position = minimap_position
		if element.poi is Player:
			element.point.rotation = element.poi.rotation + PI/2
