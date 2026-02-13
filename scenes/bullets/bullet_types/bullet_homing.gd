extends Bullet
class_name BulletHoming

@onready var trail: Line2D = $Trail
@onready var trail_position: Marker2D = $TrailPosition

func special_effects() -> void:
	draw_trail()

var queue: Array
var MAX_LENGTH: int = 10

func draw_trail() -> void:
	if !is_instance_valid(trail):
		return
	
	var pos = trail_position.global_position
	queue.push_front(pos)

	if queue.size() > MAX_LENGTH:
		queue.pop_back()

	trail.clear_points()
	for point in queue:
		trail.add_point(point)
