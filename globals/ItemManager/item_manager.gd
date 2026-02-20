extends Node

var ITEM_SCENES: Dictionary[Item.Code, PackedScene] = {
	Item.Code.DEFAULT: load("res://scenes/items/item.tscn"),
	Item.Code.METAL_SCRAP: load("res://scenes/items/metal_scrap/metal_scrap.tscn"),
	Item.Code.BIG_METAL_SCRAP: load("res://scenes/items/big_metal_scrap/big_metal_scrap.tscn"),
	Item.Code.PHASE_CRYSTAL: load("res://scenes/items/phase_crystal/phase_crystal.tscn"),
	Item.Code.BIONIC_IMPLANT: load("res://scenes/items/bionic_implant/bionic_implant.tscn"),
	Item.Code.FUSION_CORE: load("res://scenes/items/fusion_core/fusion_core.tscn"),
}

func create_item_scene(
	type: Item.Type,
	code: Item.Code,
	display_name: String,
	start_position,
	target_position)\
-> Item:
	var item: Item
	
	var scene: PackedScene = ITEM_SCENES[code]
	item = scene.instantiate()
	
	item.type = type
	item.display_name = display_name
	item.global_position = start_position
	item.target_position = target_position
	
	return item
