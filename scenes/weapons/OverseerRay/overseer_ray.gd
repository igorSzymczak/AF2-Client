extends Ray

@onready var gradient_line: Line2D = $GradientLine
@onready var gpu_particles_2d: GPUParticles2D = $GPUParticles2D


func _on_ready() -> void:
	#print("Tweening for ", time_to_live)
	
	scale = Vector2(1.0, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_BOUNCE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.3)
	
	await get_tree().create_timer(time_to_live - 0.1).timeout
	
	var tween_out: Tween = create_tween()
	tween_out.tween_property(self, "scale", Vector2(1.0, 0.0), 0.1)

func create_beam() -> void:
	gpu_particles_2d.lifetime = distance / 4000.0
	gpu_particles_2d.preprocess = gpu_particles_2d.lifetime
	
	for line in lines:
		var mod_distance: float = distance
		if line != base_line:
			mod_distance += gradient_lines_additional_distance
		
		var mid_distance: float = mod_distance / float(point_amount)
		line.clear_points()
		line.add_point(Vector2(0.0, 0.0))
		line.add_point(Vector2(mid_distance / 10.0, 0.0))
		var i: int = 1
		while line.points.size() <= point_amount:
			var point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
			line.add_point(point_position)
			i+=1
		
		var end_point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
		line.add_point(end_point_position - Vector2(mid_distance / 10.0, 0.0))
		line.add_point(end_point_position)

func set_radius(value: float) -> void:
	if !base_line or !gradient_line:
		return
	
	radius = value
	base_line.set_width(radius * 2)
	gradient_line.set_width(radius * 6)
