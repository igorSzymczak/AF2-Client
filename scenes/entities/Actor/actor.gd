class_name Actor extends CharacterBody2D

var gid: int # GameManager ID
var stats: Stats = Stats.new()
var props: PropertyContainer = PropertyContainer.new(g.ACTOR_PROPERTY_SCHEMA)
@export var actor_type: EntityManager.ActorType

@onready var sprite: Node2D = $Sprite
@onready var engine: Thruster = sprite.find_child("Engine")
@onready var health_component: HealthComponent = $HealthComponent
@onready var poi: POI = $PoiComponent

enum Event {
	TELEPORT,
	SET_AI_STATE,
	OVERSEER_DRONE_ABOUT_TO_SHOOT_RAY,
}

enum TeleportData {
	POSITION,
	EASE_IN_SEC,
	EASE_OUT_SEC
}

func _ready() -> void:
	health_component.health_depleted.connect(handle_death)
	props.property_changed.connect(_on_property_changed)

var server_pos: Vector2 = Vector2.ZERO
var server_rot: float = 0
var server_engine_active: bool
var last_pos := Vector2.ZERO
func _process(delta: float):
	global_position = global_position.lerp(server_pos, delta * 20)
	rotation = lerp_angle(rotation, server_rot, 0.2)
	
	velocity = global_position.direction_to(last_pos) * global_position.distance_to(last_pos)
	last_pos = global_position
	
	_process_ai(delta)

func _process_ai(_delta: float) -> void: pass # To be replaced by specific Actor

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

func handle_death(silent: bool = false) -> void:
	if !is_queued_for_deletion():
		poi.remove()
		queue_free()
		if !silent:
			GlobalSignals.create_explosion.emit(global_position, "explosion_medium", 1, {})

func handle_event(event: Event, event_data: Variant) -> void:
	if event == Event.TELEPORT:
		handle_teleport(event_data)
	if event == Event.SET_AI_STATE:
		handle_set_ai_state(event_data)
	if event == Event.OVERSEER_DRONE_ABOUT_TO_SHOOT_RAY:
		handle_overseer_drone_about_to_shoot_ray(event_data)

func handle_teleport(event_data) -> void:
	var teleport_position: Vector2 = event_data[TeleportData.POSITION]
	var ease_in_sec: float = event_data[TeleportData.EASE_IN_SEC]
	var ease_out_sec: float = event_data[TeleportData.EASE_OUT_SEC]
	
	var ease_in_scale_tween := create_tween()
	ease_in_scale_tween.tween_property(self, "scale", Vector2(0.001, 0.001), ease_in_sec)
	await ease_in_scale_tween.finished
	
	global_position = teleport_position
	last_pos = teleport_position
	server_pos = teleport_position
	velocity = Vector2.ZERO
	
	var ease_out_scale_tween := create_tween()
	ease_out_scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), ease_out_sec)

func handle_set_ai_state(_state) -> void: pass  # to be replaced by specific Actor class
func handle_overseer_drone_about_to_shoot_ray(_event_data) -> void: pass # Only Overseer Drone
