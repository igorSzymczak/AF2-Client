extends Actor

enum State {
	ORBIT_SPAWNER,
	DRONE_DEFENSE,
	DRONE_ATTACK_SNIPER,
	DRONE_ATTACK_SPIN,
	
	P2_TRANSFORM,
	
	P2_LASER_BARRAGE,
	P2_RAY_RUN,
	P2_MISSILES,
	P2_END
}

const TRANSFORM_SHAKE_STRENGTH: float = 20.0

@onready var drones_tp_sound: AudioStreamPlayer2D = $DronesTpSound
@onready var phase_2_transform_sound: AudioStreamPlayer2D = $Phase2TransformSound
@onready var suck_ray: Ray = $SuckRay

var attack_states: Array[State] = [
	State.DRONE_DEFENSE,
	State.DRONE_ATTACK_SNIPER,
	State.DRONE_ATTACK_SPIN,
]

var current_state: State 

func handle_set_ai_state(state: State) -> void:
	if current_state != State.ORBIT_SPAWNER and\
	state in attack_states and\
	state != State.DRONE_ATTACK_SPIN:
		drones_tp_sound.play()
	
	state_time_sec = 0.0
	
	if state == State.P2_TRANSFORM:
		phase_2_transform_sound.play()
	
	current_state = state

var state_time_sec: float = 0.0
func _process_ai(delta: float) -> void:
	state_time_sec += delta
	
	if current_state == State.P2_TRANSFORM:
		handle_transfoming(delta)

var suck_ray_created: bool = false
func handle_transfoming(_delta: float) -> void:
	var shake_strength: float = clampf(state_time_sec / 7.0, 0.0, 1.0)
	if state_time_sec > 7.0:
		shake_strength -= cos((8.0 - state_time_sec) * PI/2)
	
	var shake_offset: Vector2 = Functions.rand_vector2(0.0, TRANSFORM_SHAKE_STRENGTH * shake_strength)
	global_position = server_pos + shake_offset
	
	if state_time_sec > 5.0:
		suck_ray.show()
		var angle: float = (state_time_sec - 5.0) * PI / 3.0
		suck_ray.modulate.a = clampf(sin(angle) * 2.0, 0.0, 1.0)
	else:
		suck_ray.hide()

func handle_death(_silent: bool = false) -> void:
	if current_state != State.P2_END:
		return
	else:
		return
		actual_death()

func actual_death() -> void:
	if !is_queued_for_deletion():
		poi.remove()
		queue_free()
		GlobalSignals.create_explosion.emit(global_position, "explosion_medium", 1, {})
