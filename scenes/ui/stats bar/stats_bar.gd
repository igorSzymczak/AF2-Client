extends Control

@onready var health_noise: Sprite2D = $Background/HealthBar/Health
@onready var shield_noise: Sprite2D = $Background/ShieldBar/Shield

@onready var health_amount_label = $HealthAmountLabel
@onready var shield_amount_label = $ShieldAmountLabel


var max_health: float
var health: float

var max_shield: float
var shield: float

var default_health_offset: float
var default_shield_offset: float

func set_max_health(value: float):
	max_health = value
	draw_bars()
func set_health(value: float):
	health = value
	draw_bars()
func set_max_shield(value: float):
	max_shield = value
	draw_bars()
func set_shield(value: float):
	shield = value
	draw_bars()


func _ready() -> void:
	default_health_offset = health_noise.position.x
	default_shield_offset = shield_noise.position.x
	
	await AuthManager.joined
	
	var health_component: HealthComponent = GameManager.local_player.health_component
	health_component.max_health_changed.connect(set_max_health)
	health_component.health_changed.connect(set_health)
	health_component.max_shield_changed.connect(set_max_shield)
	health_component.shield_changed.connect(set_shield)

func _process(delta):
	if !AuthManager.is_logged_in: return
	
	shield_noise.position.x = lerpf(shield_noise.position.x, shield_pos, delta * 5)
	health_noise.position.x = lerpf(health_noise.position.x, health_pos, delta * 5)
	

var health_pos: float = 0.0
var shield_pos: float = 0.0

func draw_bars() -> void:
	health_amount_label.text = Functions.shorten_number(health)
	shield_amount_label.text = Functions.shorten_number(shield) 
	
	var bar_width: float = health_noise.get_rect().size.x * health_noise.scale.x
	
	var hp_percentage: float = health / max_health
	var sh_percentage: float = shield / max_shield
	
	health_pos = default_health_offset - bar_width * (1 - hp_percentage)
	shield_pos = default_shield_offset - bar_width * (1 - sh_percentage)
	
