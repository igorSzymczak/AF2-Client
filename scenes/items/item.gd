class_name Item extends Area2D

enum Type {
	CARGO,
}

enum Code {
	DEFAULT,
	METAL_SCRAP,
}

@export var code: Code = Code.DEFAULT
@export var display_name: String = "Default Item"
@export var type: Type = Type.CARGO
@export var target_position: Vector2

func _ready():
	var tween: Tween = create_tween()
	tween.tween_property(self, "global_position", Vector2(target_position), 1)\
		.set_trans(Tween.TRANS_EXPO)\
		.set_ease(Tween.EASE_OUT)

signal about_to_die()
func destroy():
	about_to_die.emit()
	queue_free()
