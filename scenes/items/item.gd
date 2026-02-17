class_name Item extends Area2D

enum Type {
	CARGO,
}

enum Code {
	DEFAULT,
	METAL_SCRAP,
	BIG_METAL_SCRAP,
	PHASE_CRYSTAL,
	FUSION_CORE,
	BIONIC_IMPLANT,
}

@export var code: Code = Code.DEFAULT
@export var display_name: String = "Default Item"
@export var type: Type = Type.CARGO
@export var target_position: Vector2

@onready var sprite: Sprite2D = $Sprite

func _ready():
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(target_position), 1)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)
	
	var poi: POI = POI.new()
	poi.label = display_name
	poi.type = POI.TYPE.ITEM
	add_child(poi)
	about_to_die.connect(poi.remove)


signal about_to_die()
func destroy():
	about_to_die.emit()
	g.remove_item(int(name))
	queue_free()

static func get_item_by_code(given_code: Code) -> Item:
	match given_code:
		Code.DEFAULT: return Item.new()
		Code.METAL_SCRAP: return MetalScrap.new()
		
	return Item.new()

static func get_texture_path_by_code(given_code: Code) -> String:
	match given_code:
		Code.DEFAULT: return "res://assets/items/i (1).png"
		Code.METAL_SCRAP: return "res://assets/items/i (7).png"
		Code.BIG_METAL_SCRAP: return "res://assets/items/i (5).png"
		Code.PHASE_CRYSTAL: return "res://assets/items/i (2).png"
		Code.FUSION_CORE: return "res://assets/items/i (3).png"
		Code.BIONIC_IMPLANT: return "res://assets/items/i (6).png"
	return "res://assets/items/i (1).png"
		
	
