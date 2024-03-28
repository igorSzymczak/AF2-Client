extends GPUParticles2D
var explosion_scale: float = 1.0
var particles_amount: int = 20
var particles_velocity: Vector2 = Vector2(50, 100)
var particles_alpha: float = 1.0
var particle_gradient = process_material.color_ramp

func set_args(args: Dictionary) -> void:
	if args.has("scale"):
		explosion_scale = args["scale"]
	if args.has("amount"):
		particles_amount = args["amount"]
	if args.has("velocity"):
		particles_velocity = args["velocity"]
	if args.has("alpha"):
		particles_alpha = args["alpha"]
	if args.has("gradient"):
		particle_gradient = args["gradient"]
	
	

func _ready() -> void:
	
	set_scale(Vector2(explosion_scale, explosion_scale))
	set_amount(particles_amount)
	process_material.initial_velocity_min = particles_velocity.x
	process_material.initial_velocity_max = particles_velocity.y
	self_modulate.a = particles_alpha
	process_material.color_ramp = particle_gradient
	
	emitting = true;

func _on_finished():
	queue_free()
