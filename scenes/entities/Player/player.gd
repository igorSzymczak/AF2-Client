extends CharacterBody2D
class_name Player

const TURN_SPEED := 3.0 
const DECELERATION_SPEED := 400.0
const MAX_SPEED := 500.0
const DRAG_COEF := 100.0
const SPEED := 500.0 # ship stat

var poi_type = "player"

var landed_structure: Structure = null

@onready var health_component: HealthComponent = $HealthComponent

@onready var nickname_container: PanelContainer = $Nickname
@onready var nickname_label: Label = $Nickname/MarginContainer/Label

@onready var ship: ShipComponent = $ShipComponent
@onready var engine: Thruster = $ShipComponent/Engine
@onready var camera: Camera2D = $Camera2D

var nickname: String

var IS_MAIN_PLAYER: bool

var default_label_pos: Vector2
var alive: = true
func _ready() -> void:
	nickname = name
	nickname_label.set_text(nickname)
	default_label_pos = nickname_container.position
	
	IS_MAIN_PLAYER = name == AuthManager.my_username
	
	health_component.connect("health_depleted", handle_death)
	
	if IS_MAIN_PLAYER:
		GameManager.connect("set_local_player_position", set_position_from_server)
		GameManager.connect("death_args", set_death_args)
		nickname_container.hide()
		z_index = 1

	if !IS_MAIN_PLAYER:
		camera.set_enabled(false)
		call_deferred("other_player_setup_poi")

func other_player_setup_poi():
	GlobalSignals.emit_signal("setup_poi", self)

var death_args: Dictionary
func set_death_args(args):
	death_args = args

var last_server_ship_name := ""
func _physics_process(delta: float) -> void:
	nickname_container.global_position = global_position + default_label_pos
	var server_ship_name: String = GameManager.get_player_ship_name(name)
	if last_server_ship_name != server_ship_name:
		last_server_ship_name = server_ship_name
		set_ship(last_server_ship_name)
		if IS_MAIN_PLAYER:
			GlobalSignals.close_current_ui.emit()
	
	if landed_structure == null and last_server_ship_name != ship.name:
		set_ship(last_server_ship_name)
	
	if IS_MAIN_PLAYER:
		if health_component.health > health_component.MAX_HEALTH:
			health_component._set_health(health_component.MAX_HEALTH)
			global_position = Vector2(randi_range(-5000, 5000), randi_range(-5000, 5000))
		
		
		handle_movement(delta)
		camera_zoom_out(delta)
		
		if !GameManager.PlayerInfo.is_empty():
			handle_change_weapon()
			if Input.is_action_pressed("Shoot"):
				handle_shoot()
			regen_power(delta)
		
		emit_server_signals()
	else:
		handle_other_player(delta)

var last_update_pos = 0
var last_pos = Vector2.ZERO
@onready var update_time_pos = GameManager.TIMESTEP.LOW

var last_update_rot = 0
var last_rot = 0
@onready var update_time_rot = GameManager.TIMESTEP.MEDIUM

var last_update_vel = 0
var last_vel = Vector2.ZERO
@onready var update_time_vel = GameManager.TIMESTEP.MEDIUM

var server_alive: bool = true
var death_time: int = 0

var server_nickname: String = ""

func emit_server_signals():
	if GameManager.Players.has(name):
		server_nickname = GameManager.get_player_nickname(name)
		if server_nickname != nickname:
			nickname = server_nickname
			nickname_label.set_text(nickname)
		
		server_alive = GameManager.get_player_alive(name)
		
		var t = Time.get_ticks_msec()
		if t - update_time_pos > last_update_pos && last_pos.distance_squared_to(global_position) >= 9:
			last_update_pos = t
			last_pos = global_position
			GameManager.emit_signal("local_player_position", global_position)
		
		if t - update_time_rot > last_update_rot && last_rot != rotation:
			last_update_rot = t
			last_rot = rotation
			GameManager.emit_signal("local_player_rotation", rotation)
		
		if t - update_time_vel > last_update_vel && last_vel.distance_squared_to(velocity) >= 1:
			last_update_vel = t
			last_vel = velocity
			GameManager.emit_signal("local_player_velocity", velocity)
		
		if alive and !server_alive:
			alive = false
			death_time = t
			health_component.hide()
			GlobalSignals.emit_signal("close_all_ui")
			GlobalSignals.emit_signal("set_ui", "death")
			set_modulate(Color(2, 2, 2, 0.3))
		if !alive and !server_alive:
			if death_args.has("killer") and death_args.has("respawn_time"):
				var seconds_to_respawn = death_args["respawn_time"] - roundi((t - death_time) / 1000.0)
				GlobalSignals.emit_signal("set_ui_args", {
					"killer"= death_args["killer"], 
					"respawn_time"= seconds_to_respawn
				})
		elif !alive and server_alive: 
			alive = true
			velocity = Vector2.ZERO
			health_component.show()
			GlobalSignals.emit_signal("set_ui", "game")
			set_modulate(Color(1, 1, 1, 1))

func set_position_from_server(pos: Vector2):
	global_position = pos
	GameManager.emit_signal("local_player_position", global_position)

var server_position := Vector2.ZERO
var server_rotation := 0.0
var server_velocity := Vector2.ZERO
var server_engine_active: bool = false
func handle_other_player(delta) -> void:
	if GameManager.Players.has(name):
		alive = GameManager.get_player_alive(name)
		server_nickname = GameManager.get_player_nickname(name)
		if server_nickname != nickname:
			nickname = server_nickname
			nickname_label.set_text(nickname)
		
		server_position = GameManager.get_player_position(name)
		server_rotation = GameManager.get_player_rotation(name)
		server_velocity = GameManager.get_player_velocity(name)
		server_engine_active = GameManager.get_player_engine_active(name)
		
		global_position = global_position.lerp(server_position, delta * 10)
		rotation = lerp_angle(rotation, server_rotation,  delta * 10)
		velocity = velocity.lerp(server_velocity, delta * 20)
		
		if server_engine_active:
			engine.activate_thruster()
		else:
			engine.deactivate_thruster(velocity)
		
		var is_main_player_alive = GameManager.get_player_alive(str(AuthManager.my_username))
		if landed_structure != null:
			# Alpha being set in func land_on()
			var _nothing = 0
		elif is_main_player_alive and !alive:
			hide()
			modulate.a = 0
		elif is_main_player_alive and alive: 
			show()
			set_modulate(Color(1, 1, 1, 1))
			health_component.show()
		elif !is_main_player_alive and !alive: 
			show()
			set_modulate(Color(3, 3, 3, 0.3))
			health_component.hide()
		elif !is_main_player_alive and alive: 
			show()
			set_modulate(Color(1, 1, 1, 1))
			health_component.show()
	else:
		GlobalSignals.emit_signal("delete_poi", self)
		call_deferred("queue_free")

var direction := Vector2.ZERO
func handle_movement(delta: float) -> void:
	# Rotate the player towards the mouse at a set turn speed
	if IS_MAIN_PLAYER and landed_structure == null:
		var target_rotation = global_position.angle_to_point(get_global_mouse_position())
		rotation = rotate_toward(rotation, target_rotation, TURN_SPEED * delta)
	
	if landed_structure == null:
		# Handle input. If nothing is pressed the player will slowly lose speed due to the drag coefficient
		direction = Vector2(cos(rotation), sin(rotation))
		if Input.is_action_pressed("Accelerate") and GameManager.can_perform_actions:
			velocity += direction * SPEED * delta
			velocity = velocity.limit_length(MAX_SPEED)
		elif Input.is_action_pressed("Decelerate") and GameManager.can_perform_actions:
			velocity -= velocity.normalized() * DECELERATION_SPEED * delta

		if !velocity.is_equal_approx(Vector2.ZERO):
			velocity -= velocity.normalized() * DRAG_COEF * delta
		handle_thrust()
		move_and_slide()
	
	elif landed_structure != null:
		global_position = global_position.lerp(landed_structure.global_position, delta * 5)

func handle_death() -> void:
	GlobalSignals.emit_signal("create_explosion", global_position, "explosion_large", 1, {})


var engine_active: bool
func handle_thrust() -> void:
	var old_engine_active = engine_active
	if GameManager.can_perform_actions:
		if Input.is_action_pressed("Accelerate"):
			engine.activate_thruster()
			engine_active = true
		else:
			engine.deactivate_thruster(velocity)
			engine_active = false
	
	if old_engine_active != engine_active:
		GameManager.emit_signal("local_player_engine_active", engine_active)

func handle_change_weapon() -> void:
	if !GameManager.can_perform_actions:
		return
	var num_pressed = null
	if(Input.is_action_pressed("Weapon1")): num_pressed = 1
	elif(Input.is_action_pressed("Weapon2")): num_pressed = 2
	elif(Input.is_action_pressed("Weapon3")): num_pressed = 3
	elif(Input.is_action_pressed("Weapon4")): num_pressed = 4
	elif(Input.is_action_pressed("Weapon5")): num_pressed = 5
	
	if num_pressed != null:
		GameManager.PlayerInfo["current_weapon"] = num_pressed
		
		handle_shoot()

func handle_shoot() -> void:
	if alive and GameManager.can_perform_actions and not GameManager.is_mouse_over_menu():
		var index: int = GameManager.PlayerInfo.current_weapon
		var power_usage: float = GameManager.PlayerInfo.weapons[index].power_usage
		var current_power: float = GameManager.PlayerInfo.current_power
		var shoot_delay: int = GameManager.PlayerInfo.weapons[index].shoot_delay
		var last_shot: int = GameManager.PlayerInfo.weapons[index].last_shot
		
		var t = Time.get_ticks_msec()
		if current_power >= power_usage && t - shoot_delay > last_shot:
			current_power -= power_usage
			last_shot = t
			
			GameManager.PlayerInfo.current_power = current_power
			GameManager.PlayerInfo.weapons[index].last_shot = last_shot
			
			GameManager.player_shoot.emit(index)

func regen_power(delta) -> void:
	var current_power = GameManager.PlayerInfo.current_power
	var max_power = GameManager.PlayerInfo.max_power
	var power_regen_rate = GameManager.PlayerInfo.power_regen_rate
	
	if current_power < max_power:
		var percentage_of_max = current_power / max_power
		var power_regen_multiplier = max(0.2, min(0.75, percentage_of_max))
		
		current_power += (delta * pow(PI, 3)) * power_regen_multiplier * max(1, pow(power_regen_rate, 1.0/4.0))
	current_power = min(current_power, max_power)
	GameManager.PlayerInfo.current_power = current_power

var camera_offset := Vector2.ZERO
func camera_zoom_out(delta: float) -> void:
	var zoom_value: float
	if landed_structure == null:
		zoom_value = max(0.45, 0.5 - abs(velocity.length()) * delta / 100.0)
	else:
		zoom_value = 1
	var zoom_vector: Vector2 = camera.zoom.lerp(Vector2(zoom_value, zoom_value), delta)
	
	camera.set_zoom(zoom_vector)
	GlobalSignals.emit_signal("camera_zoom", zoom_vector.x)
	
	var look_strength = 0.1
	camera_offset = camera_offset.lerp((get_global_mouse_position() - global_position) * look_strength, 0.2)
	
	camera.set_offset(camera_offset)
	GlobalSignals.emit_signal("camera_offset", camera_offset)

func set_ship(new_ship_name: String):
	if new_ship_name == ship.name: return
	
	var new_ship: ShipComponent = ShipManager.get_ship(new_ship_name)
	if new_ship == null: return
	ship.queue_free()
	add_child(new_ship)
	ship = new_ship
	engine = ship.engine

## 		Landing

func land_on(structure: Structure):
	landed_structure = structure
	health_component.hide()
	if IS_MAIN_PLAYER:
		GameManager.can_perform_actions = false
		velocity = Vector2.ZERO
		
		var rotation_tween: Tween = create_tween()
		rotation_tween.tween_property(self, "rotation", 0, 1)
		
		GlobalSignals.close_all_ui.emit()
		
		await get_tree().create_timer(0.5).timeout
		
		if landed_structure is Hangar:
			GlobalSignals.open_ui.emit("hangar")
			GlobalSignals.set_ui_args.emit(landed_structure.get_structure_data())
		
		else:
			GlobalSignals.open_ui.emit("structure")
			GlobalSignals.set_ui_args.emit(landed_structure.get_structure_data())
			
	
	elif !IS_MAIN_PLAYER:
		nickname_container.hide()
		
		var scale_tween: Tween = create_tween()
		scale_tween.tween_property(self, "scale", Vector2(0.3, 0.3), 1)
		
		await get_tree().create_timer(1).timeout
		
		if landed_structure != null:
			var alpha_tween: Tween = create_tween()
			alpha_tween.tween_property(self, "modulate:a", 0.0, 0.3)

func try_leave_structure(_username: String): pass # Only Server

func animate_leave_structure(username: String):
	if name == username:
		landed_structure = null
		health_component.show()
		if IS_MAIN_PLAYER:
			GameManager.can_perform_actions = true
		elif !IS_MAIN_PLAYER:
			nickname_container.show()
			var scale_tween: Tween = create_tween()
			scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1)
			
			var alpha_tween: Tween = create_tween()
			alpha_tween.tween_property(self, "modulate:a", 1.0, 0.3)
			
			await get_tree().create_timer(0.3).timeout

@rpc("any_peer", "call_remote", "reliable")
func request_leave_structure(username: String):
	try_leave_structure(username)

@rpc("authority", "call_local", "reliable")
func leave_structure(username: String):
	animate_leave_structure(username)
