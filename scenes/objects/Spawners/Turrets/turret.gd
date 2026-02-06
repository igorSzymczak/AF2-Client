extends Node2D
class_name SpawnerTurret

var gid: int # GameManager ID
var stats: Stats = Stats.new()

@export var turn_speed: float = 3.0
@export var death_particle_gradient: GradientTexture1D
@onready var hitbox_component: HitboxComponent = $HitboxComponent 
@onready var health_component: HealthComponent = $HealthComponent

var dead: bool = false
func is_dead() -> bool:
	return dead

func handle_death() -> void:
	if !dead:
		dead = true
		
		var particle_args = {
		"amount": 20,
		"velocity": Vector2(100, 200), 
		"scale": 1.25,
		"alpha": 0.75,
		"gradient": death_particle_gradient
		}
		GlobalSignals.emit_signal("create_explosion", global_position, "blocky", 1, particle_args)

func _ready() -> void:
	hitbox_component.set_health_component(health_component)
	health_component.connect("health_depleted", handle_death)

var server_pos: Vector2
var server_rot: float
func _process(delta):
	if g.Turrets.has(name.to_int()):
		server_pos = g.get_turret_position(name.to_int())
		global_position = global_position.lerp(server_pos, delta * 5)
		
		server_rot = g.get_turret_rotation(name.to_int())
		rotation = lerp_angle(rotation, server_rot, delta * 5)
	else:
		handle_death()
		call_deferred("queue_free")
