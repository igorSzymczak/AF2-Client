extends CharacterBody2D

@onready var engine: Thruster = $Engine
@onready var health_component: HealthComponent = $HealthComponent
@onready var weapon: Weapon = $Weapon
@onready var ai: Node2D = $AI
@onready var team: Node2D = $Team

const TURN_SPEED := 2.0
const MAX_SPEED := 400.0
const DRAG_COEF := 100.0
const SPEED := 300.0

func _ready() -> void:
	health_component.connect("health_depleted", handle_death)
	ai.initialize(self, weapon, team.team)
	weapon.initialize(team.team)

func _physics_process(delta: float) -> void:
	if !velocity.is_equal_approx(Vector2.ZERO):
		velocity -= velocity.normalized() * DRAG_COEF * delta
	move_and_slide()

func handle_hit() -> void:
	health_component.damage(20)

func handle_death() -> void:
		queue_free()

func get_team() -> int:
	return team.team
