extends CharacterBody2D

@export var engine : Thruster
@export var healthComponent : HealthComponent

func _ready() -> void:
	engine.init()
	healthComponent.connect("health_depleted", handle_death)

func _physics_process(delta: float) -> void:
	pass

func handleThrust() -> void:
	if !velocity.is_equal_approx(Vector2.ZERO):
		engine.runningState(true)
		engine.activeState(true)
	else:
		if velocity.length() <= 75.0:
			engine.activeState(false)
		engine.runningState(false)
		engine.idleState()
		engine.startState(false)

func handle_hit():
	healthComponent.damage(20)

func handle_death():
		queue_free()
