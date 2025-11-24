extends Node

func create_item_scene(
	type: Item.Type,
	code: Item.Code,
	display_name: String,
	start_position,
	target_position)\
-> Item:
	var item: Item
	
	match code:
		Item.Code.DEFAULT: item = preload("res://scenes/items/item.tscn").instantiate()
		Item.Code.METAL_SCRAP: item = preload("res://scenes/items/metal_scrap/metal_scrap.tscn").instantiate()
	
	item.type = type
	item.display_name = display_name
	item.global_position = start_position
	item.target_position = target_position
	
	return item
