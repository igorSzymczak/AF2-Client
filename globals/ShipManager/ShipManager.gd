extends Node

var Ships: Dictionary = {
	"NexarBlade": preload("res://assets/ships/Nexar Blade/nexar_blade.tscn"),
	"NexarCarrier": preload("res://assets/ships/Nexar Carrier/nexar_carrier.tscn"),
	"NexarReaver": preload("res://assets/ships/Nexar Reaver/nexar_reaver.tscn"),
	"NexarZlatte": preload("res://assets/ships/Nexar Zlatte/nexar_zlatte.tscn")
}
var ship_select_scene: PackedScene = preload("res://scenes/ui/ShipSelect/ship_select.tscn")

func get_ship(ship_name: String):
	if Ships.has(ship_name):
		return Ships[ship_name].instantiate() as ShipComponent
	else:
		return null

func create_ship_select(ship_name: String):
	var ship_scene = get_ship(ship_name)
	if ship_scene:
		var ship_select = ship_select_scene.instantiate()
		ship_select.ship_name = ship_name
		return ship_select
