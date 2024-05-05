class_name BossHealth extends Control

@onready var healthbar = $HealthBar
@onready var shieldbar = $ShieldBar

var MAX_HEALTH := 0
var HEALTH := 0
var MAX_SHIELD := 0
var SHIELD := 0

func _ready():
	healthbar.visibility = true
	healthbar.smooth_health_bar_visibility()
	shieldbar.visibility = true
	shieldbar.smooth_shield_bar_visibility()
	
	
	GlobalSignals.boss_max_health.connect(set_max_health)
	GlobalSignals.boss_health.connect(set_health)
	GlobalSignals.boss_max_shield.connect(set_max_shield)
	GlobalSignals.boss_shield.connect(set_shield)

var last_visibility_update := 0
func _process(_delta):
	var t = Time.get_ticks_msec()
	if t - 1000 > last_visibility_update:
		last_visibility_update = t
		var player_pos: Vector2 = g.get_player_position(AuthManager.my_username)
		var boss_pos: Vector2 = HomerusManager.global_position
		var distance = player_pos.distance_to(boss_pos)
		var boss_alive = HomerusManager.left_segment_alive or HomerusManager.right_segment_alive or HomerusManager.main_segment_alive
		if distance < 2500 and boss_alive:
			set_visibility(true)
		else: 
			set_visibility(false)
func set_max_health(new_max_health: int):
	MAX_HEALTH = new_max_health
	healthbar.init_health(new_max_health)
	set_health(new_max_health)

func set_health(new_health: int):
	HEALTH = new_health
	healthbar._set_health(new_health)

func set_max_shield(new_max_shield: int):
	MAX_SHIELD = new_max_shield
	shieldbar.init_shield(new_max_shield)
	set_shield(new_max_shield)

func set_shield(new_shield: int):
	SHIELD = new_shield
	shieldbar._set_shield(new_shield)

var currently_shown: bool = false
func set_visibility(visibility: bool):
	if visibility and !currently_shown:
		currently_shown = true
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 1, 0.7)
	elif !visibility and currently_shown:
		currently_shown = false
		var tween: Tween = create_tween()
		tween.tween_property(self, "modulate:a", 0, 0.7)
