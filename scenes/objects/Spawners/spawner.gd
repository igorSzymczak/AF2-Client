extends Node2D
class_name Spawner

@export var spawn_enemy_scene : PackedScene
@export var max_enemies : int = 0
@export var enemies_at_once : int = 0
@export var orbit_time_MS: float = -10000.0
@export var team: int = 1
var turrets: Array[SpawnerTurret] = []
var start_turrets: Array[SpawnerTurret]

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

func set_team(new_team: int) -> void:
	self.team = new_team
	if is_instance_valid(hitbox_component):
		hitbox_component.team = new_team

var server_pos: Vector2
var server_rot: float
var server_eye_pos: Vector2
var server_eye_trigger: bool
var server_active: bool
func _process(delta):
	#rotation = 0
	if GameManager.Spawners.has(name.to_int()):
		server_pos = GameManager.get_spawner_position(name.to_int())
		global_position = global_position.lerp(server_pos, delta * 5)
		
		server_rot = GameManager.get_spawner_rotation(name.to_int())
		sprite.rotation = lerp_angle(sprite.rotation, server_rot, 0.2)
		
		server_eye_pos = GameManager.get_spawner_eye_position(name.to_int())
		eye.position = eye.position.lerp(server_eye_pos, 0.1)
		
		server_eye_trigger = GameManager.get_spawner_eye_trigger(name.to_int())
		eye_trigger(server_eye_trigger)
		
		server_active = GameManager.get_spawner_active(name.to_int())
		if server_active and !active: activate()
		elif !server_active and active: deactivate()

func eye_trigger(trigger: bool):
	if trigger: eye.set_modulate(Color(255.0, 0, 0))
	else: eye.set_modulate(Color(1, 1, 1))

var active = true

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
	GlobalSignals.emit_signal("create_explosion", global_position, "explosion_large", 1, {})
	
	active = false
	reactivate_timer.start()
	
	eye.set_visible(false)
	sprite.set_texture(destroyed_sprite.get_texture())
	
	for turret in turrets:
		turret.handle_death()
	
	health_component.set_visible(false)
	hitbox_component.set_deferred("monitorable", false)
