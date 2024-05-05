extends Area2D
class_name Bullet

# Default values
var LIFE_TIME := 1975 # Milisecs to destroy Bullet
var LIFE_TIME_RNG := 150 # additional 0-x to LIFE_TIME 

var HIT_ANIMATION_TYPE := "bullet_regular"
var HIT_ANIMATION_QUANTITY := 4

# operating Stuff
var direction : Vector2
var rng = RandomNumberGenerator.new()
var time_to_vanish: float = 100.0

var is_deterministic : bool
var direction_speed : Vector2
var fall: float
var life_time: int
var current_life_time: int
var server_timestamp: int

@onready var initial_scale: Vector2 = $BulletSprite.get_scale()
@onready var shoot_time: int

var server_pos: Vector2

var fall_vel = 1.0
var velocity: Vector2
func _ready():
	calculated_global_position = global_position
	rotation = direction_speed.angle()
	
	## Calculate the route bullet already did on server
	#var t: int = roundi(Time.get_unix_time_from_system() * 100)
	#var latency = t - server_timestamp
	shoot_time = Time.get_ticks_msec()
	#var delta_time: int = roundi(get_physics_process_delta_time() * 1000)
	#var client_life_time := delta_time
	#while client_life_time < latency:
		#client_life_time += delta_time
		#update_position()
	#if is_deterministic:
		#global_position = calculated_global_position
	
	#print(latency)
	#print("if shoot_time + life_time - current_time <= time_to_vanish")
	
	
func _physics_process(delta: float) -> void:
	if !g.Bullets.has(name): crash_bullet()
	
	update_position()
	var server_is_deterministic = g.get_bullet_is_deterministic(name)
	if server_is_deterministic != is_deterministic:
		is_deterministic = server_is_deterministic
		if is_deterministic:
			calculated_global_position = global_position
	if !is_deterministic:
		var temp_server_pos = g.get_bullet_position(name)
		
		if temp_server_pos != server_pos:
			server_pos = temp_server_pos if temp_server_pos != Vector2.ZERO else server_pos
			velocity = server_pos - global_position
		
		global_position = global_position.lerp(server_pos + velocity, delta * 10)
		rotation = lerp_angle(rotation, velocity.angle(), delta * 10)
		
		#print("not deterministic")
	elif is_deterministic:
		global_position = calculated_global_position
		rotation = lerp_angle(rotation, vel.angle(), delta * 10)
	
	special_effects()
	bullet_scale_out()

var calculated_global_position: Vector2
var vel: Vector2
func update_position() -> void:
	var delta: float = get_physics_process_delta_time()
	
	self.fall_vel *= (1.0 - fall * delta * 60.0)
	vel = direction_speed * delta
	calculated_global_position += vel * fall_vel
	#print(fall_vel)
	

func special_effects() -> void:
	pass

func bullet_scale_out() -> void:
	var current_time: int = Time.get_ticks_msec()
	#print("if " + str(shoot_time) + " + " + str(life_time) + " - " + str(current_time) + " <= " + str(time_to_vanish))
	if shoot_time + life_time - current_time <= time_to_vanish:
		var new_scale = (shoot_time + life_time - current_time) / time_to_vanish
		$BulletSprite.set_scale(Vector2(initial_scale.x * new_scale, initial_scale.y * new_scale))
		
	if current_time - shoot_time >= life_time:
		#print("bullet destroyed")
		# Bullet Ran out of Life Time
		g.remove_bullet(name)
		queue_free()
		#print(name + " " + str(vel))

func crash_bullet() -> void:
	GlobalSignals.emit_signal("create_explosion", global_position, get_hit_animation_type(), 
						get_hit_animation_quantity(), get_bullet_hit_args())
	queue_free()

# Randomizing specs
func calculate_random_life_time() -> int: return (get_life_time() + rng.randi_range(0, get_life_time_rng()))

# Gets
func get_life_time() -> int: return LIFE_TIME
func get_life_time_rng() -> int: return LIFE_TIME_RNG
func get_hit_animation_type() -> String: return HIT_ANIMATION_TYPE
func get_hit_animation_quantity() -> int: return HIT_ANIMATION_QUANTITY

func get_bullet_hit_args() -> Dictionary:
	return {}
