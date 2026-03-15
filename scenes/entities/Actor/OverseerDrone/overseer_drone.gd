class_name OverseerDrone extends Actor

enum AboutToUseRayData {
	SECONDS_REMAINING,
	DISTANCE
}

func handle_overseer_drone_about_to_shoot_ray(event_data) -> void:
	var distance: float = event_data[AboutToUseRayData.DISTANCE]
	var seconds_remaining: float = event_data[AboutToUseRayData.SECONDS_REMAINING]
	
	spawn_telescoping_ray(distance, seconds_remaining)
	

var ray_scene: PackedScene = preload("res://scenes/weapons/OverseerDroneRay/overseer_drone_telescoping_ray.tscn")
@onready var ray_position_marker: Marker2D = $RayPosition
func spawn_telescoping_ray(ray_distance: float, seconds_remaining: float) -> void:
	var ray: Ray = ray_scene.instantiate()
	ray.is_local = true
	ray.distance = ray_distance
	ray.time_to_live = seconds_remaining
	ray.radius = 50.0
	ray.rotation = PI / 2.0
	add_child(ray)
	
