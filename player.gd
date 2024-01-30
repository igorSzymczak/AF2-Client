extends CharacterBody2D

const TURN_SPEED = 3.0
const DECELERATION_SPEED = 400.0
const MAX_SPEED = 500.0
const DRAG_COEF = 100.0
var speed = 150.0

@onready var idle = $Engine/Idle
@onready var thruster = $Engine/Accelerate
@onready var sparks = $Engine/Startup
@onready var speeding = $Engine/Speeding
@onready var light = $Engine/Light

func _ready():
	idle.emitting = true
	thruster.emitting = false
	sparks.emitting = false
	speeding.emitting = false
	light.emitting = false

func _physics_process(delta):
	var pos_diff = get_global_mouse_position() - position
	var angle = atan2(pos_diff.y, pos_diff.x)
	var direction = Vector2(cos(rotation), sin(rotation))
	# Rotate the player towards the mouse at a set turn speed
	rotation = rotate_toward(rotation, angle, TURN_SPEED * delta)

	# Handle input. If nothing is pressed the player will slowly lose speed due to the drag coefficient
	if Input.is_action_pressed("Accelerate"):
		velocity += direction * speed * delta
		velocity = velocity.limit_length(MAX_SPEED)
	elif Input.is_action_pressed("Decelerate"):
		velocity -= velocity.normalized() * DECELERATION_SPEED * delta
	elif !velocity.is_equal_approx(Vector2(0,0)):
		velocity -= velocity.normalized() * DRAG_COEF * delta
	
	handleThrust(velocity)
	
	move_and_slide()

func handleThrust(velocity):
	if Input.is_action_pressed("Accelerate"):
		idle.emitting = false
		if velocity.length() > 75.0:
			thruster.emitting = true
			sparks.emitting = false
			speeding.emitting = true
			light.emitting = true
			speed = 450
		else:
			thruster.emitting = false
			sparks.emitting = true
			speeding.emitting = false
			light.emitting = false
			speed = 150
	else:
		thruster.emitting = false
		sparks.emitting = false
		idle.emitting = true
		speeding.emitting = false

