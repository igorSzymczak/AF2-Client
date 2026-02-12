extends Node2D
class_name Turret

var gid: int # GameManager ID
var stats: Stats = Stats.new()
var props: PropertyContainer = PropertyContainer.new(g.TURRET_PROPERTY_SCHEMA)

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
	health_component.health_depleted.connect(handle_death)
	props.property_changed.connect(_on_property_changed)

func _on_property_changed(prop: g.TurretProperty, value: Variant) -> void:
	match prop:
		g.TurretProperty.GID:
			gid = value
		g.TurretProperty.TURRET_TYPE:
			pass
		g.TurretProperty.GLOBAL_POSITION:
			server_pos = value
		g.TurretProperty.ROTATION:
			server_rot = value
		g.TurretProperty.HEALTH:
			health_component.health = value
		g.TurretProperty.SHIELD:
			health_component.shield = value

var server_pos: Vector2
var server_rot: float
func _process(delta):
	if !g.Turrets.has(gid):
		handle_death()
		call_deferred("queue_free")
		return
	
	global_position = global_position.lerp(server_pos, delta * 4)
	rotation = lerp_angle(rotation, server_rot, delta * 4)
