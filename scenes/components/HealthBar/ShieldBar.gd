extends ProgressBar
class_name ShieldBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var shield: float = 0 : set = _set_shield
var visibility: bool = false

var initial_position: Vector2
func _ready() -> void:
	initial_position = position

func _physics_process(delta):
	global_position = get_parent().get_parent().global_position + initial_position
	
	if abs(value - shield) > max_value / 1000.0:
		value = lerpf(value, shield, delta * 5)
	else:
		value = shield

var combo_start: float
func _set_shield(new_shield: float) -> void:
	shield = max(0, min(max_value, new_shield))
	
	if shield < combo_start:
		damage_bar.value = combo_start
		timer.start()
		print(str(shield) + " < " + str(combo_start))
	else:
		damage_bar.value = 0
		combo_start = shield
	
	if shield <= 0:
		shield = 0
	
	smooth_shield_bar_visibility()
	
func init_shield(_shield: float):
	max_value = _shield
	damage_bar.max_value = _shield
	
	if value > max_value:
		_set_shield(_shield)
	
	modulate.a = 0
	smooth_shield_bar_visibility()
	
func _on_timer_timeout():
	damage_bar.value = 0
	combo_start = shield

func smooth_shield_bar_visibility() -> void:
	if !get_parent() is BossHealth: 
		if visibility and shield == max_value:
			visibility = false
		elif !visibility and shield != max_value:
			visibility = true
		
	var target_alpha = 1.0 if visibility else 0.0
	var duration = 0.3
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, duration)
