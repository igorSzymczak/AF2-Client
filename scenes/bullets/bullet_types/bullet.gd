extends Area2D
class_name Bullet

var gid: int
var props: PropertyContainer = PropertyContainer.new(g.BULLET_PROPERTY_SCHEMA)

# Default values
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

@onready var sprite: Sprite2D = $BulletSprite
@onready var initial_scale: Vector2 = sprite.get_scale() if is_instance_valid(sprite) else Vector2.ZERO
@onready var shoot_time: int

var server_pos: Vector2

var fall_vel = 1.0
var velocity: Vector2
func _ready():
	rotation = direction_speed.angle()
	
	shoot_time = Time.get_ticks_msec()
	
	props.property_changed.connect(_handle_property_changed)
	
	special_ready()

var opacity: float = 0.0
func special_ready() -> void:
	# For special effects :)
	var tween: Tween = create_tween()
	tween.tween_property(self, "opacity", 1.0, 0.1)

func _handle_property_changed(prop: g.BulletProperty, value: Variant) -> void:
	match prop:
		g.BulletProperty.GID:
			gid = value
		g.BulletProperty.BULLET_TYPE:
			pass
		g.BulletProperty.GLOBAL_POSITION:
			#global_position = value
			calculated_global_position = value
			server_pos = value
			velocity = server_pos - global_position
		g.BulletProperty.IS_DETERMINISTIC:
			is_deterministic = value
		g.BulletProperty.DIRECTION_SPEED:
			direction_speed = value
			rotation = direction_speed.angle()
		g.BulletProperty.FALL:
			fall = value
		g.BulletProperty.LIFE_TIME:
			life_time = value
		g.BulletProperty.CURRENT_LIFE_TIME:
			current_life_time = value
		g.BulletProperty.IS_DETERMINISTIC:
			server_timestamp = value
		
		

func _physics_process(delta: float) -> void:
	if !g.Bullets.has(gid): crash_bullet()
	
	update_position(delta)
	
	special_effects()
	bullet_scale_out()

var calculated_global_position: Vector2
var vel: Vector2
func update_position(delta: float) -> void:
	if is_deterministic:
		self.fall_vel *= (1.0 - fall * delta * 60.0)
		vel = direction_speed * delta
		calculated_global_position += vel * fall_vel
		global_position = calculated_global_position
		rotation = lerp_angle(rotation, vel.angle(), delta * 10)
	else:
		global_position = global_position.lerp(server_pos + velocity, delta * 10)
		rotation = lerp_angle(rotation, velocity.angle(), delta * 10)

func special_effects() -> void:
	# special effects every frame
	modulate.a = opacity

func bullet_scale_out() -> void:
	var current_time: int = Time.get_ticks_msec()
	if shoot_time + life_time - current_time <= time_to_vanish:
		var new_scale = (shoot_time + life_time - current_time) / time_to_vanish
		sprite.set_scale(Vector2(initial_scale.x * new_scale, initial_scale.y * new_scale))
		
	if current_time - shoot_time >= life_time:
		# Bullet Ran out of Life Time
		g.remove_bullet(gid)
		queue_free()

func crash_bullet() -> void:
	GlobalSignals.create_explosion.emit(global_position, get_hit_animation_type(), 
						get_hit_animation_quantity(), get_bullet_hit_args())
	queue_free()

# Gets
func get_life_time() -> int: return life_time
func get_life_time_rng() -> int: return LIFE_TIME_RNG
func get_hit_animation_type() -> String: return HIT_ANIMATION_TYPE
func get_hit_animation_quantity() -> int: return HIT_ANIMATION_QUANTITY

func get_bullet_hit_args() -> Dictionary:
	return {}
