class_name ShipComponent extends Sprite2D

enum SHADER {
	SPEED_BOOST,
	HEAL,
	DAMAGE_BOOST,
	SHIELD,
}

@onready var lights: Sprite2D = $Lights 
@export var engine: Thruster

@export var ship_name := "Default Ship Name"
@export var hangar_scale := Vector2(0.6, 0.6)

@export var health := 5
@export var armor := 5
@export var shield := 5
@export var shield_regen := 5

@export var base_health := 50
@export var base_armor := 50
@export var base_shield := 50
@export var base_shield_regen := 50

var effect_sprite: Sprite2D = null  # kopia statku dla aktualnego efektu

# trzymamy aktywne instancje efektów
var active_effects := {}  # { SHADER : Sprite2D }
var shaders: Node2D

func _ready() -> void:
	shaders = Node2D.new()
	shaders.rotation = -PI / 2.0
	shaders.scale = Vector2(1.2, 1.2)
	add_child(shaders)

func _process(delta: float) -> void:
	# speed boost jako przykład efektu dynamicznego
	if active_effects.has(SHADER.SPEED_BOOST):
		_update_speed_boost(delta)


# -----------------------------------------------------
# PUBLIC: wywołanie efektu
# -----------------------------------------------------
func apply_shader(effect: SHADER) -> void:
	if active_effects.has(effect):
		return  # efekt już działa

	# utwórz nową kopię sprite'a
	var inst: Sprite2D = _create_effect_sprite()
	shaders.add_child(inst)
	active_effects[effect] = inst

	# nadaj materiał efektu
	_apply_initial_material_state(effect, inst)


# -----------------------------------------------------
# PUBLIC: wygaszenie efektu
# -----------------------------------------------------
func remove_shader(effect: SHADER) -> void:
	if not active_effects.has(effect):
		return
	
	var inst: Sprite2D = active_effects[effect]
	active_effects.erase(effect)

	_fade_and_delete(inst)


# -----------------------------------------------------
# EFEKT: SPEED BOOST — dynamiczne aktualizacje
# -----------------------------------------------------
func _update_speed_boost(delta: float) -> void:
	var inst: Sprite2D = active_effects[SHADER.SPEED_BOOST]
	var mat := inst.material

	var parent: Node2D = get_parent()
	var max_speed: float = parent.MAX_SPEED
	var velocity: float = ((parent.velocity.length()) - max_speed) * delta

	mat.set("shader_parameter/stretch", 3.0 * velocity)
	mat.set("shader_parameter/blur_strength", 0.5 * velocity)
	mat.set("shader_parameter/glow_strength", max(1.0, 0.5 * velocity))
	mat.set("shader_parameter/margin", min(0.02, 0.01 * velocity))


# -----------------------------------------------------
# TWORZENIE SPRITE KOPII
# -----------------------------------------------------
func _create_effect_sprite() -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = position
	sprite.rotation = rotation
	sprite.scale = scale
	sprite.z_index = z_index + 1  # efekt nad oryginałem
	return sprite


# -----------------------------------------------------
# START PARAMETRÓW DLA EFEKTÓW
# -----------------------------------------------------
func _apply_initial_material_state(effect: SHADER, inst: Sprite2D) -> void:
	match effect:

		SHADER.SPEED_BOOST:
			inst.material = preload("res://shaders/Abilities/SpeedBoost/sprite.tscn").instantiate().material.duplicate(true)

		SHADER.HEAL:
			inst.material = preload("res://shaders/Abilities/Heal/sprite.tscn").duplicate(true)

		SHADER.DAMAGE_BOOST:
			inst.material = preload("res://shaders/Abilities/DamageBoost/sprite.tscn").duplicate(true)

		SHADER.SHIELD:
			inst.material = preload("res://shaders/Abilities/Shield/sprite.tscn").duplicate(true)


# -----------------------------------------------------
# WYGASZENIE → USUNIĘCIE EFEKTU
# -----------------------------------------------------
func _fade_and_delete(inst: Sprite2D) -> void:
	var mat := inst.material
	if not mat:
		inst.queue_free()
		return

	# Zbieramy wszystkie parametry, które shader posiada.
	var params := {}
	for param in mat.get_property_list():
		if !param.name.contains("shader_parameter/"):
			continue
		
		var value = mat.get(param.name)
		
		# Możesz filtrować, jeśli tylko niektóre mają być wygaszane
		if typeof(value) == TYPE_FLOAT:
			params[param.name] = value

	# Jeśli nic nie ma do wygaszania → delete
	if params.is_empty():
		inst.queue_free()
		return
	
	# Tween równoległy
	var tween := create_tween().set_parallel(true)
	for param_name in params.keys():
		var start_value: float = params[param_name]

		# Tweening method that changes parameter values directly
		tween.tween_method(func method(i): mat.set((param_name), i), start_value, 0.0, 1)

	tween.finished.connect(func():
		inst.queue_free()
	)
