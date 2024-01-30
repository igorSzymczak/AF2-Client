extends CharacterBody2D

const TURN_SPEED = 3.0
const DECELERATION_SPEED = 400.0
const MAX_SPEED = 500.0
const DRAG_COEF = 100.0
var speed = 150.0

@export var engine : Thruster

func _ready():
	engine.init()

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
	
	handleThrust()
	move_and_slide()

func handleThrust():
	if Input.is_action_pressed("Accelerate"):
		if velocity.length() > 75.0:
			engine.runningState(true)
			engine.activeState(true)
			engine.startState(false)
			speed = 450
		else:
			engine.runningState(false)
			engine.startState(true)
			engine.activeState(false)
			speed = 150
	else:
		if velocity.length() <= 75.0:
			engine.activeState(false)
		engine.runningState(false)
		engine.idleState()
		engine.startState(false)

