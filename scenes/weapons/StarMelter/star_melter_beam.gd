extends Beam

@onready var launch_sound: AudioStreamPlayer2D = $LaunchSound
func _on_ready() -> void:
	launch_sound.play()

@export var bg_line: Line2D
@export var pulse_particles: GPUParticles2D
@export var end_particles: GPUParticles2D
func create_beam() -> void:
	if !base_line or !bg_line:
		return
	
	pulse_particles.lifetime = (distance / 1000.0)
	pulse_particles.visibility_rect = Rect2(0, -100, distance + 100, 200)
	#pulse_particles.preprocess = 0
	end_particles.position.x = distance - 225.0
	
	var lines: Array[Line2D] = [base_line, bg_line]
	for line in lines:
		var mid_distance: float = distance / float(point_amount)
		#print("Making dupa")
		line.clear_points()
		line.add_point(Vector2(0.0, 0.0))
		line.add_point(Vector2(mid_distance / 5.0, 0.0))
		var i: int = 1
		while line.points.size() < point_amount:
			var point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
			line.add_point(point_position)
			i+=1
		
		var end_point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
		line.add_point(end_point_position - Vector2(mid_distance / 5.0, 0.0))
		line.add_point(end_point_position)
