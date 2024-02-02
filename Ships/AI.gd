extends Node2D

signal state_changed(new_state)

enum State {
	ENGAGE,
	ORBIT
}

@onready var detection_zone: Area2D = $DetectionZone
@onready var aiming_at: Marker2D = $AimingAt

var current_state: State = State.ORBIT : set = set_state
var target: CharacterBody2D = null
var weapon: Weapon = null
var actor: CharacterBody2D = null
var team: int = -1

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	match current_state:
		State.ORBIT:
			actor.engine.deactivate_thruster(actor.velocity)
		State.ENGAGE:
			if target != null and weapon != null:
				var angle_to_player: float = actor.global_position.direction_to(target.global_position).angle()
				var angle_of_actor: Vector2 = actor.global_position.direction_to(aiming_at.global_position)
				actor.rotation = rotate_toward(actor.rotation, angle_to_player, actor.TURN_SPEED * delta)

				actor.velocity += angle_of_actor.normalized() * actor.SPEED * delta
				actor.velocity = actor.velocity.limit_length(actor.MAX_SPEED)
				actor.engine.activate_thruster()

				if abs(angle_of_actor.angle() - angle_to_player) <= 0.3:
					weapon.shoot()
			else:
				print("dependencies uninitialized")

func initialize(actor: CharacterBody2D, weapon: Weapon, team: int) -> void:
	self.actor = actor
	self.weapon = weapon
	self.team = team

func set_state(new_state: State) -> void:
	if(new_state == current_state):
		return
	current_state = new_state
	emit_signal("state_changed", current_state)

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ENGAGE)
		target = body

func _on_chase_zone_body_exited(body: Node2D) -> void:
	if body.has_method("get_team") and body.get_team() != team:
		set_state(State.ORBIT)
		target = null
