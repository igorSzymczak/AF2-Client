extends CharacterBody2D

const TURN_SPEED := 3.0
const DECELERATION_SPEED := 400.0
const MAX_SPEED := 500.0
const DRAG_COEF := 100.0

var speed := 225.0
var direction := Vector2.ZERO

@onready var bullet_spawn: Marker2D = $BulletSpawn
@onready var bullet_direction: Marker2D = $BulletDirection

@export var engine : Thruster
@export var bullet_scene : PackedScene
@onready var cooldown: Timer = $Cooldown

signal player_fired_weapon(bullet: Bullet, position: Vector2, direction: Vector2)


func _ready() -> void:
	engine.init()

func _physics_process(delta: float) -> void:
	# Rotate the player towards the mouse at a set turn speed
	var pos_diff = get_global_mouse_position() - global_position
	rotation = rotate_toward(rotation, atan2(pos_diff.y, pos_diff.x), TURN_SPEED * delta)

	if Input.is_action_pressed("Shoot"):
		shoot()

	# Handle input. If nothing is pressed the player will slowly lose speed due to the drag coefficient
	direction = Vector2(cos(rotation), sin(rotation))
	if Input.is_action_pressed("Accelerate"):
		velocity += direction * speed * delta
		velocity = velocity.limit_length(MAX_SPEED)
	elif Input.is_action_pressed("Decelerate"):
		velocity -= velocity.normalized() * DECELERATION_SPEED * delta

	if !velocity.is_equal_approx(Vector2(0,0)):
		velocity -= velocity.normalized() * DRAG_COEF * delta

	handleThrust()
	move_and_slide()


func shoot() -> void:
	if cooldown.is_stopped():
		var bullet = bullet_scene.instantiate()
		var d = -(bullet_spawn.global_position-bullet_direction.global_position).normalized()
		emit_signal("player_fired_weapon", bullet, bullet_spawn.global_position, d)
		cooldown.start()


func handleThrust() -> void:
	if Input.is_action_pressed("Accelerate"):
		if velocity.length() > 75.0:
			engine.runningState(true)
			engine.activeState(true)
			engine.startState(false)
			speed = 500
		else:
			engine.runningState(false)
			engine.startState(true)
			engine.activeState(false)
			speed = 225
	else:
		if velocity.length() <= 75.0:
			engine.activeState(false)
		engine.runningState(false)
		engine.idleState()
		engine.startState(false)

