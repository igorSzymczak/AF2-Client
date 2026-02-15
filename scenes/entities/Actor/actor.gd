class_name Actor extends CharacterBody2D

var gid: int # GameManager ID
var stats: Stats = Stats.new()
var props: PropertyContainer = PropertyContainer.new(g.ACTOR_PROPERTY_SCHEMA)
@export var actor_type: EntityManager.ActorType

@onready var sprite: Sprite2D = $Sprite
@onready var engine: Thruster = sprite.find_child("Engine")
@onready var health_component: HealthComponent = $HealthComponent
@export var poi_type = "enemy"

func _ready() -> void:
	health_component.health_depleted.connect(handle_death)
	GlobalSignals.emit_signal("setup_poi", self)
	props.property_changed.connect(_on_property_changed)

var server_pos: Vector2 = Vector2.ZERO
var server_rot: float = 0
var server_engine_active: bool
var last_pos := Vector2.ZERO
func _process(delta: float):
	global_position = global_position.lerp(server_pos, delta * 10)
	rotation = lerp_angle(rotation, server_rot, 0.2)
	
	velocity = global_position.direction_to(last_pos) * global_position.distance_to(last_pos)

func _on_property_changed(prop: g.ActorProperty, value: Variant) -> void:
	match prop:
		g.ActorProperty.GID:
			gid = value
		g.ActorProperty.ACTOR_TYPE:
			actor_type = value
		g.ActorProperty.GLOBAL_POSITION:
			server_pos = value
		g.ActorProperty.ROTATION:
			server_rot = value
		g.ActorProperty.HEALTH:
			health_component.health = value
		g.ActorProperty.SHIELD:
			health_component.shield = value
		g.ActorProperty.ENGINE_ACTIVE:
			if !is_instance_valid(engine):
				return
			
			if value: 	engine.activate_thruster()
			else: 		engine.deactivate_thruster(velocity)

func handle_death() -> void:
	if !is_queued_for_deletion():
		GlobalSignals.emit_signal("delete_poi", self)
		GlobalSignals.emit_signal("create_explosion", global_position, "explosion_medium", 1, {})
		queue_free()
