extends Node

enum ShipType {
	NEXAR_BLADE,
	NEXAR_CARRIER,
	NEXAR_REAVER,
	NEXAR_ZLATTE,
	SHIBA
}
var ship_select_scene: PackedScene = load("res://scenes/ui/ShipSelect/ship_select.tscn")

var ship_scenes: Dictionary[ShipType, PackedScene] = {
	ShipType.NEXAR_BLADE: load("res://assets/ships/Nexar Blade/nexar_blade.tscn"),
	ShipType.NEXAR_CARRIER: load("res://assets/ships/Nexar Carrier/nexar_carrier.tscn"),
	ShipType.NEXAR_REAVER: load("res://assets/ships/Nexar Reaver/nexar_reaver.tscn"),
	ShipType.NEXAR_ZLATTE: load("res://assets/ships/Nexar Zlatte/nexar_zlatte.tscn"),
	ShipType.SHIBA: load("res://assets/ships/Shiba/Shiba.tscn"),
}

func get_ship(ship_type: ShipType) -> ShipComponent:
	var ship_component: ShipComponent = ship_scenes[ship_type].instantiate() as ShipComponent
	return ship_component

func create_ship_select(ship_type: ShipType):
	var ship: ShipComponent = get_ship(ship_type)
	print("I want to make a ship_select, did i succed?")
	if ship:
		print("Yes!")
		var ship_select: ShipSelect = ship_select_scene.instantiate()
		ship_select.ship_type = ship_type
		return ship_select

@rpc("any_peer", "call_remote", "reliable")
func request_buy_ship(username: String, ship_type: ShipType):
	handle_buy_ship(username, ship_type)

@rpc("any_peer", "call_remote", "reliable")
func request_select_ship(username: String, ship_type: ShipType):
	handle_select_ship(username, ship_type)

func handle_buy_ship(_username, _ship_name): pass # Only Server
func handle_select_ship(_username, _ship_name): pass # Only Server
