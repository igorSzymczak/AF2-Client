extends ProgressBar
class_name HealthBar

@onready var timer = $Timer
@onready var damage_bar = $DamageBar

var health: float = 0 : set = _set_health
var visibility: bool = false

var initial_position: Vector2
func _ready() -> void:
	initial_position = position

func _physics_process(delta):
	global_position = get_parent().get_parent().global_position + initial_position
	
	if abs(value - health) > max_value / 1000.0:
		value = lerpf(value, health, delta * 5)
	else:
		value = health

var combo_start: float
func _set_health(new_health: float) -> void:
	health = max(0, min(max_value, new_health))
			
	if health < combo_start:
		damage_bar.value = combo_start
		timer.start()
	else:
		damage_bar.value = 0
		combo_start = health
	
	if health <= 0:
		hide()
	else: show()
	
	smooth_health_bar_visibility()
	
func init_health(_health):
	max_value = _health
	damage_bar.max_value = _health
	
	if value > max_value:
		_set_health(max_value)
	
	modulate.a = 0
	smooth_health_bar_visibility()
	
func _on_timer_timeout():
	damage_bar.value = 0
	combo_start = health

func smooth_health_bar_visibility() -> void:
	if !get_parent() is BossHealth: 
		if visibility and health == max_value:
			visibility = false
		elif !visibility and health != max_value:
			visibility = true
			
	var target_alpha = 1.0 if visibility else 0.0
	var duration = 0.3
	
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate:a", target_alpha, duration)
