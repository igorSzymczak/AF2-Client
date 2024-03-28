extends GPUParticles2D
var explosion_scale: float = 1.0
var particle_scale: Vector2 = Vector2(1.4, 1.6)
var particles_amount: int = 1
var particles_velocity: Vector2 = Vector2(50, 100)
var particles_alpha: float = 1.0
var particles_lifetime: float = 3.0

func set_args(args: Dictionary) -> void:
	if args.has("scale"): explosion_scale = args["scale"]
	if args.has("particle_scale"): particle_scale = args["particle_scale"]
	if args.has("amount"): particles_amount = args["amount"]
	if args.has("velocity"): particles_velocity = args["velocity"]
	if args.has("alpha"): particles_alpha = args["alpha"]
	if args.has("lifetime"): particles_lifetime = args["lifetime"]

func _ready() -> void:
		#push_warning("before: " + str(process_material.get_param_min(8)) + " " + str(process_material.get_param_max(8)))
		
		set_scale(Vector2(explosion_scale, explosion_scale))
		process_material.set_param_min(8, particle_scale.x) 
		process_material.set_param_max(8, particle_scale.y)
		set_amount(particles_amount)
		process_material.initial_velocity_min = particles_velocity.x
		process_material.initial_velocity_max = particles_velocity.y
		self_modulate.a = particles_alpha
		lifetime = particles_lifetime
		
		#push_warning("after: " + str(process_material.get_param_min(8)) + " " + str(process_material.get_param_max(8)))
		emitting = true;

func _on_finished():
	queue_free()
