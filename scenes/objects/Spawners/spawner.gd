extends Node2D
class_name Spawner

var gid: int # GameManager ID
var props: PropertyContainer = PropertyContainer.new(g.SPAWNER_PROPERTY_SCHEMA)
var stats: Stats = Stats.new()

@export var spawner_type: EntityManager.SpawnerType
@export var spawn_enemy_scene : PackedScene
@export var max_enemies : int = 0
@export var enemies_at_once : int = 0
@export var orbit_time_MS: float = -10000.0
@export var team: int = 1
var turrets: Array[Turret] = []
var start_turrets: Array[Turret]

@onready var spawn_timer: Timer = $SpawnTimer
@onready var reactivate_timer = $ReactivateTimer
@onready var sprite = $SpawnerSprite
@onready var turret_holder = $TurretHolder
@onready var eye = $Eye
@onready var destroyed_sprite = $DestroyedSpawnerSprite
@onready var health_component = $HealthComponent
@onready var hitbox_component = $HitboxComponent

var poi_type = "spawner"

#var player: Player = null
#func set_player(emitted_player: Player) -> void:
	#player = emitted_player

var shoot_range: float
 
var original_sprite_texture: Texture2D
func _ready() -> void:
	GlobalSignals.emit_signal("setup_poi", self)
	
	original_sprite_texture = sprite.get_texture()
	props.property_changed.connect(_on_property_changed)

func _on_property_changed(prop: g.SpawnerProperty, value: Variant) -> void:
	match prop:
		g.SpawnerProperty.GID:
			gid = value
		g.SpawnerProperty.SPAWNER_TYPE:
			spawner_type = value
		g.SpawnerProperty.GLOBAL_POSITION:
			server_pos = value
		g.SpawnerProperty.ROTATION:
			server_rot = value
		g.SpawnerProperty.HEALTH:
			health_component.health = value
		g.SpawnerProperty.SHIELD:
			health_component.shield = value
		g.SpawnerProperty.ACTIVE:
			if value: activate()
			else: deactivate()

func set_team(new_team: int) -> void:
	self.team = new_team
	if is_instance_valid(hitbox_component):
		hitbox_component.team = new_team

var server_pos: Vector2
var server_rot: float
#var server_eye_pos: Vector2
#var server_eye_trigger: bool
func _process(delta):
	global_position = global_position.lerp(server_pos, delta * 5)
	sprite.rotation = lerp_angle(sprite.rotation, server_rot, 0.2)
	pass
	#rotation = 0
		
		#server_eye_pos = g.get_spawner_eye_position(name.to_int())
		#eye.position = eye.position.lerp(server_eye_pos, 0.1)
		#
		#server_eye_trigger = g.get_spawner_eye_trigger(name.to_int())
		#eye_trigger(server_eye_trigger)

func eye_trigger(trigger: bool):
	if trigger: eye.set_modulate(Color(255.0, 0, 0))
	else: eye.set_modulate(Color(1, 1, 1))

var active: bool = false
func activate() -> void:
	active = true
	
	# Bring back Look
	eye.set_visible(true)
	sprite.set_texture(original_sprite_texture)
	
	# Regen Turrets and hp
	health_component._set_health(health_component.max_health)
	health_component._set_shield(health_component.max_shield)
	
	# set Amount of Enemies to just the Existing ones (0 if all killed)
	
	health_component.set_visible(true)
	hitbox_component.set_monitorable(true)
	GlobalSignals.emit_signal("setup_poi", self)

func deactivate() -> void:
	GlobalSignals.emit_signal("delete_poi", self)
	GlobalSignals.create_explosion.emit(global_position, "explosion_large", 1, {})
	
	active = false
	reactivate_timer.start()
	
	eye.set_visible(false)
	sprite.set_texture(destroyed_sprite.get_texture())
	
	for turret in turrets:
		turret.handle_death()
	
	health_component.set_visible(false)
	hitbox_component.set_deferred("monitorable", false)
