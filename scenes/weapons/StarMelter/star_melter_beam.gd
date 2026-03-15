extends Beam

@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
@onready var humming_sound: AudioStreamPlayer2D = $Humming

func _on_ready() -> void:
	scale = Vector2.ZERO
	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), fade_time_sec)

func set_has_target(value: bool) -> void:
	has_target = value
	if has_target:
		modulate = Color(1, 1, 1, 1)
		pulse_particles.speed_scale = 2.0
		humming_sound.pitch_scale = 1.25
		humming_sound.volume_db = -10.0
	else:
		modulate = Color(1, 1, 1, 0.7)
		pulse_particles.speed_scale = 1.0
		humming_sound.pitch_scale = 1.0
		humming_sound.volume_db = -13.0

@export var fade_time_sec: float = 0.25
@export var bg_line: Line2D
@export var pulse_particles: GPUParticles2D
@export var end_particles: GPUParticles2D
func create_beam() -> void:
	if !base_line or !bg_line:
		return
	
	pulse_particles.lifetime = (distance / 1000.0) + 0.2
	pulse_particles.visibility_rect = Rect2(0, -100, distance + 100, 200)
	#pulse_particles.preprocess = 0
	end_particles.position.x = distance
	
	var lines: Array[Line2D] = [base_line, bg_line]
	for line in lines:
		var mid_distance: float = distance / float(point_amount)
		#print("Making dupa")
		line.clear_points()
		line.add_point(Vector2(0.0, 0.0))
		line.add_point(Vector2(mid_distance / 5.0, 0.0))
		var i: int = 1
		while line.points.size() <= point_amount:
			var point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
			line.add_point(point_position)
			i+=1
		
		var end_point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
		line.add_point(end_point_position - Vector2(mid_distance / 5.0, 0.0))
		line.add_point(end_point_position)

func _handle_death() -> void:
	var scale_tween: Tween = create_tween()
	scale_tween.tween_property(self, "scale", Vector2.ZERO, fade_time_sec)
	
	var alpha_tween: Tween = create_tween()
	alpha_tween.tween_property(self, "modulate", Color(1,1,1,0.0), fade_time_sec)
	
	var volume_1_tween: Tween = create_tween()
	volume_1_tween.tween_property(launch_sound, "volume_db", -15.0, fade_time_sec)
	
	var volume_2_tween: Tween = create_tween()
	volume_2_tween.tween_property(humming_sound, "volume_db", -15.0, fade_time_sec)
	
	
	await scale_tween.finished
	queue_free()
