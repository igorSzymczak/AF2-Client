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

func handle_transfoming(delta: float) -> void:
	var shake_strength: float = clampf(state_time_sec / 7.0, 0.0, 1.0)
	if state_time_sec > 7.0:
		shake_strength -= cos((8.0 - state_time_sec) * PI/2)
	
	var shake_offset: Vector2 = Functions.rand_vector2(0.0, TRANSFORM_SHAKE_STRENGTH * shake_strength)
	global_position = server_pos + shake_offset
