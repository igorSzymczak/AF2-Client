class_name Item extends Area2D

enum Code {
	DEFAULT,
	METAL_SCRAP,
	BIG_METAL_SCRAP,
	PHASE_CRYSTAL,
	FUSION_CORE,
	BIONIC_IMPLANT,
}

var gid: int
var props: PropertyContainer = PropertyContainer.new(g.ITEM_PROPERTY_SCHEMA)
@export var code: Code = Code.DEFAULT
@export var display_name: String = "Default Item"
var target_position: Vector2
var inside_amount: int = 1
var pickup_delay_sec: float = 0.0
var disappear_delay_sec: float = 10.0

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


var spawned: bool = false
var pickable: bool = false
var animating_disappear: bool = false
func _physics_process(delta: float) -> void:
	if !spawned:
		return
	
	if !pickable:
		pickup_delay_sec -= delta
		if pickup_delay_sec <= 0:
			pickable = true
			print("Pickable true")
	
	if disappear_delay_sec <= 0.0:
		destroy()
	else:
		disappear_delay_sec -= delta
		
		if disappear_delay_sec <= PI / 12.0:
			var scale_factor: float = sin(disappear_delay_sec * 4.0) * 1.0
			modulate.a = scale_factor
			scale = Vector2(scale_factor, scale_factor)
		elif disappear_delay_sec <= PI * 3.0:
			var scale_factor: float = cos(disappear_delay_sec * 4.0) * 0.25 + 0.75
			modulate.a = scale_factor
			
			scale = Vector2(scale_factor, scale_factor)
		

func animate_disappear() -> void:
	var tween_opacity: Tween = create_tween()
	var tween_scale: Tween = create_tween()
	while true:
		tween_opacity.tween_property(self, "modulate", Color(1, 1, 1, 0.5), 0.5)
		tween_scale.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
		await tween_opacity.finished
		tween_opacity.stop()
		tween_scale.stop()
		
		tween_opacity.tween_property(self, "modulate", Color(1, 1, 1, 1.0), 0.5)
		tween_scale.tween_property(self, "scale", Vector2(1.0, 1.0), 0.5)
		await tween_opacity.finished
		tween_opacity.stop()
		tween_scale.stop()
	
	
signal about_to_die()
func destroy():
	about_to_die.emit()
	g.remove_item(gid)
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
