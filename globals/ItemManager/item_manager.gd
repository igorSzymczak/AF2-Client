extends Node

var ITEM_SCENES: Dictionary[Item.Code, PackedScene] = {
	Item.Code.DEFAULT: load("res://scenes/items/item.tscn"),
	Item.Code.METAL_SCRAP: load("res://scenes/items/metal_scrap/metal_scrap.tscn"),
	Item.Code.BIG_METAL_SCRAP: load("res://scenes/items/big_metal_scrap/big_metal_scrap.tscn"),
	Item.Code.PHASE_CRYSTAL: load("res://scenes/items/phase_crystal/phase_crystal.tscn"),
	Item.Code.BIONIC_IMPLANT: load("res://scenes/items/bionic_implant/bionic_implant.tscn"),
	Item.Code.FUSION_CORE: load("res://scenes/items/fusion_core/fusion_core.tscn"),
}

func get_item(code: Item.Code) -> Item:
	return ITEM_SCENES[code].instantiate()
