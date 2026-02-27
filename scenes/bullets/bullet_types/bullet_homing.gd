extends Bullet
class_name BulletHoming

@onready var trail: Line2D = $Trail
@onready var trail_position: Marker2D = $TrailPosition

func special_effects(_delta: float) -> void:
	draw_trail()

var MAX_LENGTH: int = 10

func draw_trail() -> void:
	if !is_instance_valid(trail):
		return
	
	var pos = trail_position.global_position
	trail.add_point(pos, 0)

	var points_amount: int = trail.points.size()
	if points_amount > MAX_LENGTH:
		trail.remove_point(points_amount - 1)
