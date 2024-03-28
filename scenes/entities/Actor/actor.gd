class_name Actor extends CharacterBody2D

@onready var engine: Thruster = $Sprite/Engine
@onready var health_component: HealthComponent = $HealthComponent
@export var poi_type = "enemy"

func _ready() -> void:
	health_component.connect("health_depleted", handle_death)
	GlobalSignals.emit_signal("setup_poi", self)

var server_pos: Vector2 = Vector2.ZERO
var server_rot: float = 0
var server_engine_active: bool
var last_pos := Vector2.ZERO
func _process(_delta):
	if GameManager.Enemies.has(name.to_int()):
		last_pos = global_position
		server_pos = GameManager.get_enemy_position(name.to_int())
		global_position = global_position.lerp(server_pos, 0.2)
		
		server_rot = GameManager.get_enemy_rotation(name.to_int())
		rotation = lerp_angle(rotation, server_rot, 0.2)
		
		server_engine_active = GameManager.get_enemy_engine_active(name.to_int())
		var vel = global_position.direction_to(last_pos) * global_position.distance_to(last_pos)
		if server_engine_active: engine.activate_thruster()
		elif !server_engine_active: engine.deactivate_thruster(vel)
	else:
		handle_death()

func handle_death() -> void:
	if !is_queued_for_deletion():
		GlobalSignals.emit_signal("delete_poi", self)
		GlobalSignals.emit_signal("create_explosion", global_position, "explosion_medium", 1, {})
		queue_free()
