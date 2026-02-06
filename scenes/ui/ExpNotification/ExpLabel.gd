extends Label

@export var pos := Vector2i.ZERO

var current_exp := 0
var no_update_time := 5.0

func _ready():
	EXP.exp_added.connect(_on_exp_added)
	modulate.a = 0

func _process(delta):
	no_update_time += delta
	
	if no_update_time >= 4.0:
		modulate.a = lerpf(modulate.a, 0.0, delta * 3.0)
	else:
		modulate.a = lerpf(modulate.a, 1.0, delta * 3)

func _on_exp_added(exp_addition: int):
	if no_update_time < 5:
		current_exp += exp_addition
	else:
		current_exp = exp_addition
	
	var ratio: float = min(1.0, float((current_exp * 2.0) / EXP.goal_exp))
	add_theme_font_size_override("font_size", roundi(20.0 * (1.0 + ratio * 0.5)))
	
	set_text("+" + str(current_exp) + "xp")
	
	no_update_time = 0
