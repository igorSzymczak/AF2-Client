class_name Shadow extends Node2D

var parent: Sprite2D
var shadow: Sprite2D

func _ready() -> void:
	await get_tree().create_timer(get_process_delta_time()).timeout
	parent = get_parent()
	
	shadow = parent.duplicate()
	var shadow_children: Array[Node] = shadow.get_children()
	if shadow_children.size() > 0:
		for child: Node in shadow_children:
			child.queue_free()
	
	shadow.top_level = true
	shadow.global_position = parent.global_position + Vector2(20.0, 20.0)
	shadow.show_behind_parent = true
	shadow.modulate = Color(0, 0, 0, 0.333)
	add_child(shadow)
	

func _process(_delta: float) -> void:
	if !parent:
		return
	shadow.global_rotation = parent.global_rotation
	shadow.global_position = parent.global_position + Vector2(20.0, 20.0)
	
