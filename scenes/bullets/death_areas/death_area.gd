class_name DeathArea extends Area2D

var gid: int
var props := PropertyContainer.new(g.DEATH_AREA_PROPERTY_SCHEMA)
@export var death_area_type: WeaponManager.DeathAreaType
@export var start_size: float = 1000.0
@export var end_size: float = 2000.0
@export var time_to_live_sec: float = 5.0
@export var damage_delay_sec: float = 0.2
@export var create_death_lines: bool = false : set = handle_create_death_lines

@onready var death_lines: RigidBody2D = $Background/DeathLines

@export var collision: CollisionShape2D

var size: float = 0.0

@onready var background: Sprite2D = $Background
@onready var aura: Sprite2D = $AuraRed


func _ready() -> void:
	set_size(start_size)
	props.property_changed.connect(_on_property_changed)

func _on_property_changed(prop: g.DeathAreaProperty, value: Variant) -> void:
	match prop:
		g.DeathAreaProperty.GID:
			gid = value
		g.DeathAreaProperty.DEATH_AREA_TYPE:
			death_area_type = value
		g.DeathAreaProperty.GLOBAL_POSITION:
			global_position = value
		g.DeathAreaProperty.ROTATION:
			rotation = value
		g.DeathAreaProperty.TIME_TO_LIVE:
			time_to_live_sec = value
		g.DeathAreaProperty.LIFE_TIME:
			life_time_sec = value
		g.DeathAreaProperty.START_SIZE:
			start_size = value
		g.DeathAreaProperty.SIZE:
			size = value
		g.DeathAreaProperty.END_SIZE:
			end_size = value
		g.DeathAreaProperty.CREATE_DEATH_LINES:
			create_death_lines = value
		
		

var life_time_sec: float = 0.0
func _process(delta: float) -> void:
	life_time_sec += delta
	
	var increase_factor: float = (end_size - start_size) * delta / time_to_live_sec
	set_size(size + increase_factor)
	
	if life_time_sec >= time_to_live_sec:
		handle_death()

func set_start_size(value: float) -> void:
	start_size = value
	if !size:
		size = value
	
	if collision and life_time_sec == 0.0:
		set_size(start_size)

func set_end_size(value: float) -> void:
	end_size = value

var aura_width: float = 800.0
var bg_width: float = 104.0
func set_size(value: float) -> void:
	size = clampf(value, 0.0, INF)
	if !collision or !background or !aura:
		return
	
	collision.shape.radius = size
	var aura_factor: float = (size * 2) / aura_width
	var bg_factor: float = (size * 2) / bg_width
	aura.scale = Vector2(aura_factor, aura_factor)
	background.scale = Vector2(bg_factor, bg_factor)

func handle_create_death_lines(value: bool) -> void:
	if value == create_death_lines:
		return
	
	create_death_lines = value
	if create_death_lines:
		death_lines.visible = true
	else:
		death_lines. visible = false

func handle_death() -> void:
	g.remove_death_area(gid)
	queue_free()
