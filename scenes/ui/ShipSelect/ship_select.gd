class_name ShipSelect extends BetterButton

@export var engine_active: bool = false

@export var ship_name: String
@onready var ship_control: Control = %ShipControl
@onready var ship_label: Label = %ShipLabel

var ship_component: ShipComponent = null
func _ready():
	ship_component = ShipManager.get_ship(ship_name)
	if !ship_component: 
		push_error("Ship Component not specified!")
		return
	add_child(ship_component)
	
	if !engine_active: ship_component.engine.queue_free()
	ship_component.set_rotation(0)
	ship_component.set_scale(ship_component.hangar_scale)
	var new_control_size = ship_component.get_rect().size / 2.0
	new_control_size = Vector2(new_control_size.x / 1.5, new_control_size.y * 1.2)
	
	ship_control.custom_minimum_size = new_control_size
	custom_minimum_size = new_control_size
	
	ship_component.position = ship_control.position + Vector2(new_control_size.x, new_control_size.y / 2.0)
	
	ship_label.text = ship_component.ship_name
	ship_label.position.y = new_control_size.y/2.0
