extends Node2D

signal state_changed(new_state)

enum State {
	ENGAGE,
	ORBIT
}

@onready var detection_zone: Area2D = $DetectionZone
@onready var aiming_at: Marker2D = $AimingAt

var current_state: State = -1 : set = set_state
var player: Player = null
var weapon: Weapon = null
var actor: CharacterBody2D = null

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	match current_state:
		State.ORBIT:
			actor.deactivate_thruster()
		State.ENGAGE:
			if player != null and weapon != null:
				var angle_to_player: float = actor.global_position.direction_to(player.global_position).angle()
				var angle_of_actor: Vector2 = actor.global_position.direction_to(aiming_at.global_position)
				actor.rotation = rotate_toward(actor.rotation, angle_to_player, actor.TURN_SPEED * delta)

				actor.velocity += angle_of_actor.normalized() * actor.SPEED * delta
				actor.velocity = actor.velocity.limit_length(actor.MAX_SPEED)
				actor.activate_thruster()

				if abs(angle_of_actor.angle() - angle_to_player) <= 0.3:
					weapon.shoot(actor)
			else:
				print("dependencies uninitialized")

func initialize(actor: CharacterBody2D, weapon: Weapon) -> void:
	self.actor = actor
	self.weapon = weapon

func set_state(new_state: State) -> void:
	if(new_state == current_state):
		return

	current_state = new_state
	emit_signal("state_changed", current_state)

func _on_detection_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_state(State.ENGAGE)
		player = body

func _on_chase_zone_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		set_state(State.ORBIT)
		player = null
