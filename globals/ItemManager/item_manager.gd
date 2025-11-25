extends Node

const ITEM_SCENES: Dictionary[Item.Code, PackedScene] = {
	Item.Code.DEFAULT: preload("res://scenes/items/item.tscn"),
	Item.Code.METAL_SCRAP: preload("res://scenes/items/metal_scrap/metal_scrap.tscn"),
	Item.Code.BIG_METAL_SCRAP: preload("res://scenes/items/big_metal_scrap/big_metal_scrap.tscn"),
	Item.Code.PHASE_CRYSTAL: preload("res://scenes/items/phase_crystal/phase_crystal.tscn"),
	Item.Code.BIONIC_IMPLANT: preload("res://scenes/items/bionic_implant/bionic_implant.tscn"),
	Item.Code.FUSION_CORE: preload("res://scenes/items/fusion_core/fusion_core.tscn"),
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
