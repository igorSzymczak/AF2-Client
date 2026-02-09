class_name Collector extends Node2D

const SUCK_SPEED = 1000;

var sucked_items: Array[Item] = []

@onready var suckArea: Area2D = $SuckArea
@onready var collectArea: Area2D = $CollectArea

func _ready() -> void:
	suckArea.area_entered.connect(_on_suck_area_area_entered)
	collectArea.area_entered.connect(_on_collect_area_area_entered)

func _process(delta: float) -> void:
	for item: Item in sucked_items:
		if !is_instance_valid(item):
			g.remove_item(int(item.name))
			sucked_items.erase(item)
			return
		var direction = item.global_position.direction_to(global_position)
		item.global_position += direction * SUCK_SPEED * delta

func _on_suck_area_area_entered(item: Area2D) -> void:
	if item is Item and not sucked_items.has(item) and is_instance_valid(item):
		sucked_items.append(item)
		item.about_to_die.connect(func del(): sucked_items.erase(item))

func _on_collect_area_area_entered(item: Area2D) -> void:
	if item is Item:
		item.destroy()
