extends Bullet
class_name Torpedo

func get_life_time() -> int: return 400
func get_life_time_rng() -> int: return 50

func get_hit_animation_type() -> String: return "bullet_regular"
func get_hit_animation_quantity() -> int: return 4
func get_bullet_hit_args() -> Dictionary: return {"color": Color(2, 194, 255), "scale": 1.0}

@onready var trail_left: Line2D = $LineLeft
@onready var trail_right: Line2D = $LineRight

@onready var trail_right_position: Marker2D = $LineRightPosition
@onready var trail_left_position: Marker2D = $LineLeftPosition

var trails: Array[Line2D]

func special_ready() -> void:
	trails = [trail_left, trail_right]
	trail_left.clear_points()
	trail_right.clear_points()

func special_effects(_delta: float) -> void:
	draw_trail()

var MAX_LENGTH: int = 10

func draw_trail() -> void:
	for trail: Line2D in trails:
		if !is_instance_valid(trail):
			return
		
		var pos: Vector2
		if trail == trail_left:
			pos = trail_left_position.global_position - trail_left_position.position
		if trail == trail_right:
			pos = trail_right_position.global_position - trail_right_position.position
		trail.add_point(pos, 0)
		
		var points_amount: int = trail.points.size()
		if points_amount > MAX_LENGTH:
			trail.remove_point(points_amount - 1)
