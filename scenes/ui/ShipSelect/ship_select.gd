extends Control

@export var engine_active: bool = false

@export var ship_component: ShipComponent
@onready var ship_control: Control = %ShipControl
@onready var ship_label: Label = %ShipLabel

func _ready():
	if !ship_component: 
		push_error("Ship Component not specified!")
		return
	
	if !engine_active: ship_component.engine.queue_free()
	ship_component.set_rotation(0)
	ship_component.set_scale(ship_component.hangar_scale)
	var new_control_size = ship_component.get_rect().size / 2.0
	
	ship_control.custom_minimum_size = new_control_size
	custom_minimum_size = new_control_size
	
	ship_component.position = ship_control.position + Vector2(new_control_size.x, new_control_size.y / 2.0)
	
	ship_label.text = ship_component.ship_name
