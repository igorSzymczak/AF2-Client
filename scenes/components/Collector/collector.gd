class_name Collector extends Node2D

const SUCK_SPEED = 1000;

var sucked_items: Array[Item] = []

@onready var suckArea: Area2D = $SuckArea
@onready var collectArea: Area2D = $CollectArea

var player: Player

func _ready() -> void:
	player = get_parent()
	await player.ready
	player.health_component.health_depleted.connect(sucked_items.clear)
	
	suckArea.area_entered.connect(_on_suck_area_area_entered)
	suckArea.area_exited.connect(_on_suck_area_area_exited)
	collectArea.area_entered.connect(_on_collect_area_area_entered)

func _process(delta: float) -> void:
	if !player.alive or player.landed_structure != null:
		return
	
	for item: Item in sucked_items:
		if !is_instance_valid(item):
			sucked_items.erase(item)
			return
		var direction: Vector2 = item.global_position.direction_to(global_position)
		item.global_position += direction * SUCK_SPEED * delta

func _on_suck_area_area_entered(item: Area2D) -> void:
	if item is Item and !sucked_items.has(item) and is_instance_valid(item) and player.alive:
		sucked_items.append(item)
		item.about_to_die.connect(func del(): sucked_items.erase(item))

func _on_suck_area_area_exited(item: Area2D) -> void:
	if item is Item and sucked_items.has(item):
		sucked_items.erase(item)

func _on_collect_area_area_entered(item: Area2D) -> void:
	if item is Item and player.alive:
		item.destroy()
