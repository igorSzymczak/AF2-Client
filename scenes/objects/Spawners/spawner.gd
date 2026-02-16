extends Node2D
class_name Spawner

var gid: int # GameManager ID
var props: PropertyContainer = PropertyContainer.new(g.SPAWNER_PROPERTY_SCHEMA)
var stats: Stats = Stats.new()

@export var spawner_type: EntityManager.SpawnerType
@export var team: int = 1

@onready var sprite = $SpawnerSprite
@onready var eye = $Eye
@onready var destroyed_sprite = $DestroyedSpawnerSprite
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $HitboxComponent
@onready var poi: POI = $PoiComponent

#var player: Player = null
#func set_player(emitted_player: Player) -> void:
	#player = emitted_player

var shoot_range: float
 
var original_sprite_texture: Texture2D
func _ready() -> void:
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
	poi.visible = true
	
	# Bring back Look
	eye.set_visible(true)
	sprite.set_texture(original_sprite_texture)
	
	# Regen Turrets and hp
	health_component._set_health(health_component.max_health)
	health_component._set_shield(health_component.max_shield)
	
	# set Amount of Enemies to just the Existing ones (0 if all killed)
	
	health_component.set_visible(true)
	hitbox_component.set_monitorable(true)

func deactivate() -> void:
	GlobalSignals.create_explosion.emit(global_position, "explosion_large", 1, {})
	
	active = false
	poi.visible = false
	
	eye.set_visible(false)
	sprite.set_texture(destroyed_sprite.get_texture())
	
	health_component.set_visible(false)
	hitbox_component.set_deferred("monitorable", false)
