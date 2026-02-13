extends CharacterBody2D
class_name Player

var gid: int # GameManager ID

var stats: Stats = Stats.new()
var props: PropertyContainer = PropertyContainer.new(g.PLAYER_PROPERTY_SCHEMA)

const TURN_SPEED := 3.0 
const DECELERATION_SPEED := 400.0
const MAX_SPEED := 500.0
const DRAG_COEF := 100.0
const SPEED := 500.0 # ship stat

var poi_type = "player"

var landed_structure: Structure = null

@onready var health_component: HealthComponent = $HealthComponent

@onready var nickname_container: PanelContainer = %NicknameContainer
@onready var nickname_label: Label = %NicknameLabel
@onready var lvl_label: Label = %LvlLabel

@onready var ship: ShipComponent = $ShipComponent
@onready var engine: Thruster = $ShipComponent/Engine
@onready var camera: Camera2D = $Camera2D
@onready var reticle: Sprite2D = $Reticle

var username: String
var nickname: String = "Player"

var IS_MAIN_PLAYER: bool

var default_label_pos: Vector2
var alive: = true
var user_prefs: UserPreferences
func _ready() -> void:
	user_prefs = UserPreferences.load_or_create()
	
	name = nickname
	
	if props.get_property(g.PlayerProperty.USERNAME) == "zlattepl":
		nickname_label.add_theme_color_override("font_color", Color(1, 0.811, 0.25))
	
	default_label_pos = nickname_container.position
	
	IS_MAIN_PLAYER = gid == AuthManager.my_user_id
	
	health_component.health_depleted.connect(handle_death)
	props.property_changed.connect(_on_property_changed)
	
	if IS_MAIN_PLAYER:
		StatManager.my_stats = stats
		nickname_container.hide()
		z_index = 1
		g.update.connect(emit_server_signals)
	else:
		camera.set_enabled(false)
		call_deferred("other_player_setup_poi")
		reticle.hide()
	
	print("HEY IM PLAYER AND IM CREATED YAY, \tmy id is ", gid)

func other_player_setup_poi():
	GlobalSignals.emit_signal("setup_poi", self)

var monitorable: bool = false
func _on_property_changed(prop: g.PlayerProperty, value: Variant) -> void:
	match prop:
		g.PlayerProperty.USERNAME:
			username = value
		g.PlayerProperty.NICKNAME:
			nickname = value
			nickname_label.set_text(nickname)
		g.PlayerProperty.GLOBAL_POSITION:
			server_position = value
		g.PlayerProperty.ROTATION:
			server_rotation = value
		g.PlayerProperty.VELOCITY:
			server_velocity = value
		g.PlayerProperty.ENGINE_ACTIVE:
			if value: engine.activate_thruster()
			else: engine.deactivate_thruster(velocity)
		g.PlayerProperty.HEALTH:
			health_component.health = value
		g.PlayerProperty.SHIELD:
			health_component.shield = value
		g.PlayerProperty.ALIVE:
			handle_alive_changed(value)
		g.PlayerProperty.SHIP_NAME:
			set_ship(value)
			if IS_MAIN_PLAYER:
				GlobalSignals.close_current_ui.emit()
		g.PlayerProperty.LVL:
			lvl_label.set_text(str(value) + " lvl")
		g.PlayerProperty.SPEED_BOOST:
			speed_boost_active = value
		g.PlayerProperty.MONITORABLE:
			monitorable = value

func _physics_process(delta: float) -> void:
	nickname_container.global_position = global_position + default_label_pos
	if IS_MAIN_PLAYER:
		handle_movement(delta)
		camera_zoom_out(delta)
		
		if !g.PlayerInfo.is_empty():
			handle_change_weapon()
			if Input.is_action_pressed("Shoot"):
				handle_shoot()
			regen_power(delta)
		
		handle_reticle(delta)
		
	else:
		handle_other_player(delta)

var last_pos = Vector2.ZERO
var last_rot = 0
var last_vel = Vector2.ZERO

var death_time: int = 0

var server_nickname: String = ""

func handle_alive_changed(server_alive) -> void:
	if alive and !server_alive:
		alive = false
		health_component.hide()
		set_modulate(Color(2, 2, 2, 0.3))
		if IS_MAIN_PLAYER:
			GlobalSignals.close_all_ui.emit()
			GlobalSignals.set_ui.emit("death")
	elif !alive and server_alive: 
		alive = true
		velocity = Vector2.ZERO
		health_component.show()
		set_modulate(Color(1, 1, 1, 1))
		if IS_MAIN_PLAYER:
			GlobalSignals.emit_signal("set_ui", "game")

func emit_server_signals():
	if g.Players.has(gid):
		if last_pos.distance_squared_to(global_position) >= 9:
			last_pos = global_position
			g.local_player_property_changed.emit(g.PlayerProperty.GLOBAL_POSITION, global_position)
		
		if last_rot != rotation:
			last_rot = rotation
			g.local_player_property_changed.emit(g.PlayerProperty.ROTATION, rotation)
		
		if last_vel.distance_squared_to(velocity) >= 1:
			last_vel = velocity
			g.local_player_property_changed.emit(g.PlayerProperty.VELOCITY, velocity)

func set_position_from_server(pos: Vector2):
	global_position = pos
	velocity = Vector2.ZERO

var server_position := Vector2.ZERO
var server_rotation := 0.0
var server_velocity := Vector2.ZERO
func handle_other_player(delta: float) -> void:
	if !is_instance_valid(g.me):
		return
	if !g.Players.has(gid):
		GlobalSignals.emit_signal("delete_poi", self)
		call_deferred("queue_free")
		return
	
	global_position = global_position.lerp(server_position, delta * 10)
	rotation = lerp_angle(rotation, server_rotation,  delta * 10)
	velocity = velocity.lerp(server_velocity, delta * 20)
	
		
	var is_main_player_alive: bool = g.me.alive
	if landed_structure != null:
		pass # Alpha being set in func land_on()
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


var momentum_speed_cap: float = MAX_SPEED
var speed_boost_strength: float = 2.0
var speed_boost_active: bool = false : set = set_speed_boost
var speed_boost_duration: float = 1.5 #s
var speed_boost_delay: float = 3.0 #s
var speed_boost_turn_speed: float = 0.2
var last_speed_boost_time: float = 0.0 # s

var direction := Vector2.ZERO

func set_speed_boost(value: bool) -> void:
	if speed_boost_active and !value:
		ship.remove_shader(ship.SHADER.SPEED_BOOST)
	elif !speed_boost_active and value:
		ship.apply_shader(ship.SHADER.SPEED_BOOST)
	
	speed_boost_active = value

func handle_movement(delta: float) -> void:
	# SpeedBoost
	manage_speed_boost(delta)
	
	
	
	# Rotation
	var speed_boost_rotation_mult: float = speed_boost_turn_speed if speed_boost_active else 1.0
	var mod_turn_speed: float = TURN_SPEED * delta * speed_boost_rotation_mult
	
	if !user_prefs.disable_mouse_aim:
		if IS_MAIN_PLAYER and landed_structure == null:
			var mouse_pos: Vector2 = get_global_mouse_position()
			var target_rotation: float = global_position.angle_to_point(mouse_pos)
			rotation = rotate_toward(rotation, target_rotation, mod_turn_speed)
	
	elif user_prefs.disable_mouse_aim:
		if Input.is_action_pressed("SlowTurn"):
			mod_turn_speed *= 0.33
		
		if Input.is_action_pressed("TurnLeft") and Input.is_action_pressed("TurnRight"):
			pass
		elif Input.is_action_pressed("TurnLeft"):
			rotation = rotate_toward(rotation, rotation + PI, mod_turn_speed)
		elif Input.is_action_pressed("TurnRight"):
			rotation = rotate_toward(rotation, rotation - PI, mod_turn_speed)
		
		# Position
	if landed_structure == null:
		direction = Vector2(cos(rotation), sin(rotation))

		# jeśli boost trwa → aktualizujemy maksymalny osiągnięty "moment"
		if speed_boost_active:
			momentum_speed_cap = MAX_SPEED * speed_boost_strength

		# przyspieszanie albo aktywny boost
		if (Input.is_action_pressed("Accelerate") and g.can_perform_actions) or speed_boost_active:
			var boost_mul = speed_boost_strength if speed_boost_active else 1.0
			velocity += direction * SPEED * delta * 1.5 * boost_mul

			# UŻYWAMY momentum_speed_cap zamiast stałego MAX_SPEED
			velocity = velocity.limit_length(momentum_speed_cap)
		# hamowanie
		elif Input.is_action_pressed("Decelerate") and g.can_perform_actions:
			velocity -= velocity.normalized() * DECELERATION_SPEED * delta

		# naturalny opór
		if !velocity.is_equal_approx(Vector2.ZERO):
			velocity -= velocity.normalized() * DRAG_COEF * delta / 2.5
		else:
			velocity = Vector2.ZERO
		
		if momentum_speed_cap > MAX_SPEED:
			momentum_speed_cap -= DRAG_COEF * delta / 2.5
		elif momentum_speed_cap > velocity.length():
			momentum_speed_cap = max(MAX_SPEED, velocity.length())

		handle_thrust()
		move_and_slide()

	
	elif landed_structure != null:
		global_position = global_position.lerp(landed_structure.global_position, delta * 5)

func manage_speed_boost(delta: float) -> void:
	last_speed_boost_time += delta
	if Input.is_action_just_pressed("SpeedBoost") and !speed_boost_active and last_speed_boost_time > speed_boost_delay and g.can_perform_actions:
		speed_boost_active = true
		last_speed_boost_time = 0.0
		ship.apply_shader(ship.SHADER.SPEED_BOOST)
		g.local_player_property_changed.emit(g.PlayerProperty.SPEED_BOOST, speed_boost_active)
	
	if last_speed_boost_time > speed_boost_duration and speed_boost_active:
		speed_boost_active = false
		ship.remove_shader(ship.SHADER.SPEED_BOOST)
		g.local_player_property_changed.emit(g.PlayerProperty.SPEED_BOOST, speed_boost_active)

func handle_death() -> void:
	GlobalSignals.create_explosion.emit(global_position, "explosion_large", 1, {})

func handle_reticle(delta: float):
	if user_prefs.reticle:
		var power: float = min(1.0, max(0.0, velocity.length() / 100.0))
		var reticle_scale: float = 1.0 + sin( float(Time.get_ticks_msec()) / 250.0 ) / 5.0
			
		reticle.global_rotation += delta * power
		reticle.scale = Vector2(reticle_scale, reticle_scale)
		if !alive:
			reticle.self_modulate.a = lerpf(reticle.self_modulate.a, 0, delta * 5) 
		else:
			reticle.self_modulate.a = lerpf(reticle.self_modulate.a, 1, delta * 5) 
	else:
		reticle.self_modulate.a = lerpf(reticle.self_modulate.a, 0, delta * 5) 

var engine_active: bool
func handle_thrust() -> void:
	if g.can_perform_actions:
		if Input.is_action_pressed("Accelerate") or speed_boost_active:
			engine.activate_thruster()
			engine_active = true
			g.local_player_property_changed.emit(g.PlayerProperty.ENGINE_ACTIVE, engine_active)
		else:
			engine.deactivate_thruster(velocity)
			engine_active = false
			g.local_player_property_changed.emit(g.PlayerProperty.ENGINE_ACTIVE, engine_active)
	

func handle_change_weapon(num_pressed: int = 0) -> void:
	if !g.can_perform_actions:
		return
	
	if num_pressed != 0: pass
	elif(Input.is_action_pressed("Weapon1")): num_pressed = 1
	elif(Input.is_action_pressed("Weapon2")): num_pressed = 2
	elif(Input.is_action_pressed("Weapon3")): num_pressed = 3
	elif(Input.is_action_pressed("Weapon4")): num_pressed = 4
	elif(Input.is_action_pressed("Weapon5")): num_pressed = 5
	
	if num_pressed != 0:
		g.PlayerInfo["current_weapon"] = num_pressed
		
		handle_shoot()

func handle_shoot() -> void:
	if alive and g.can_perform_actions and not g.is_mouse_over_menu() and monitorable:
		
		var index: int = g.PlayerInfo.current_weapon
		var power_usage: float = g.PlayerInfo.weapons[index].power_usage
		var current_power: float = g.PlayerInfo.current_power
		var shoot_delay: int = g.PlayerInfo.weapons[index].shoot_delay
		var last_shot: int = g.PlayerInfo.weapons[index].last_shot
		
		var t = Time.get_ticks_msec()
		if current_power >= power_usage && t - shoot_delay > last_shot:
			current_power -= power_usage
			last_shot = t
			
			g.PlayerInfo.current_power = current_power
			g.PlayerInfo.weapons[index].last_shot = last_shot
			
			g.player_shoot.emit(index)

func regen_power(delta) -> void:
	var current_power = g.PlayerInfo.current_power
	var max_power = g.PlayerInfo.max_power
	var power_regen_rate = g.PlayerInfo.power_regen_rate
	
	if current_power < max_power:
		var percentage_of_max = current_power / max_power
		var power_regen_multiplier = max(0.3, min(0.75, percentage_of_max))
		
		current_power += (delta * pow(PI, 3)) * power_regen_multiplier * max(1, pow(power_regen_rate, 1.0/4.0))
	current_power = min(current_power, max_power)
	g.PlayerInfo.current_power = current_power

var camera_offset := Vector2.ZERO
func camera_zoom_out(delta: float) -> void:
	var zoom_value: float
	if landed_structure == null:
		zoom_value = max(0.37, 0.42 - abs(velocity.length()) / 10000.0)
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
	print("TRYING TO LAND")
	landed_structure = structure
	health_component.hide()
	if IS_MAIN_PLAYER:
		g.can_perform_actions = false
		velocity = Vector2.ZERO
		
		var rotation_tween: Tween = create_tween()
		rotation_tween.tween_property(self, "rotation", 0, 1)
		
		GlobalSignals.close_all_ui.emit()
		
		await get_tree().create_timer(0.5).timeout
		
		if landed_structure is Hangar:
			GlobalSignals.open_ui.emit("hangar")
			GlobalSignals.set_ui_args.emit(landed_structure.get_structure_data())
		
		elif is_instance_valid(landed_structure):
			GlobalSignals.open_ui.emit("structure")
			GlobalSignals.set_ui_args.emit(landed_structure.get_structure_data())
		else:
			GlobalSignals.open_ui.emit("structure")
		
	
	elif !IS_MAIN_PLAYER:
		nickname_container.hide()
		
		var scale_tween: Tween = create_tween()
		scale_tween.tween_property(self, "scale", Vector2(0.3, 0.3), 1)
		
		await get_tree().create_timer(1).timeout
		
		if landed_structure != null:
			var alpha_tween: Tween = create_tween()
			alpha_tween.tween_property(self, "modulate:a", 0.0, 0.3)

func try_leave_structure(_user_id: int): pass # Only Server

func animate_leave_structure():
	print("Animating Leaving structure ")
	landed_structure = null
	health_component.show()
	if IS_MAIN_PLAYER:
		g.can_perform_actions = true
	elif !IS_MAIN_PLAYER:
		nickname_container.show()
		var scale_tween: Tween = create_tween()
		scale_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 1)
		
		var alpha_tween: Tween = create_tween()
		alpha_tween.tween_property(self, "modulate:a", 1.0, 0.3)
		
		await get_tree().create_timer(0.3).timeout
