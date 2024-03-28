extends Control

@onready var health_noise: Sprite2D = $Background/HealthBar/Health
@onready var shield_noise: Sprite2D = $Background/ShieldBar/Shield

@onready var health_amount_label = $HealthAmountLabel
@onready var shield_amount_label = $ShieldAmountLabel


var max_health: float
var health: float

var max_shield: float
var shield: float

func set_health(player_health: float) -> void:
	health = player_health
	if !max_health:
		max_health = health
func set_shield(player_shield: float) -> void:
	shield = player_shield
	if !max_shield:
		max_shield = shield

var default_health_offset: float
var default_shield_offset: float

func _ready() -> void:
	GlobalSignals.connect("player_health", set_health)
	GlobalSignals.connect("player_shield", set_shield)
	
	default_health_offset = health_noise.position.x
	default_shield_offset = shield_noise.position.x
func _process(_delta):
	draw_bars()

func draw_bars() -> void:
	health_amount_label.text = str(round(health))
	shield_amount_label.text = str(round(shield))
	
	var bar_width = health_noise.get_rect().size.x * health_noise.scale.x
	
	var hp_percentage = health / max_health
	var sh_percentage = shield / max_shield
	
	health_noise.position.x = default_health_offset - bar_width * (1 - hp_percentage)
	shield_noise.position.x = default_shield_offset - bar_width * (1 - sh_percentage)
	
