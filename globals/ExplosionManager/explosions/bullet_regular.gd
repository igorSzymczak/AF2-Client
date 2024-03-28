extends Area2D

@export var velocity_range: float = 3.0
@export var vanish_speed: float = 10

@onready var rng = RandomNumberGenerator.new() 
@onready var velocity: Vector2 = Vector2(rng.randf_range(-velocity_range, velocity_range), rng.randf_range(-velocity_range, velocity_range))

var alpha = 1
func _process(delta):
	global_position += velocity
	
	velocity -= velocity * delta * 4
	alpha = max(0, alpha - delta * 2)
	modulate.a = alpha
	if alpha <= 0.01: queue_free()

func set_args(args: Dictionary):
	var color = Color(1,1,1)
	var animation_scale = 1
	if args.has("color"):
		color = args["color"]
	else: push_warning("No color specified")
	
	if args.has("scale"):
		animation_scale = args["scale"]
	else: push_warning("No scale specified")
	
		
	set_scale(Vector2(animation_scale, animation_scale))
	set_modulate(Color(color.r / 255.0, color.g/255.0, color.b/255.0))
	
