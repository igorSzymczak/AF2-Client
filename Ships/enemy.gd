extends CharacterBody2D

@export var engine : Thruster
@export var health_component : HealthComponent

@onready var weapon: Weapon = $Weapon
@onready var ai: Node2D = $AI

const TURN_SPEED := 2.0
const MAX_SPEED := 400.0
const DRAG_COEF := 100.0
const SPEED := 300.0

func _ready() -> void:
	health_component.connect("health_depleted", handle_death)
	ai.initialize(self, weapon)

func _physics_process(delta: float) -> void:
	if !velocity.is_equal_approx(Vector2.ZERO):
		velocity -= velocity.normalized() * DRAG_COEF * delta
	move_and_slide()

func activate_thruster() -> void:
	engine.runningState(true)
	engine.activeState(true)

func deactivate_thruster() -> void:
	if velocity.length() <= 75.0:
		engine.activeState(false)
	engine.runningState(false)
	engine.idleState()

func handle_hit() -> void:
	health_component.damage(20)

func handle_death() -> void:
		queue_free()
