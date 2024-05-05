extends ProgressBar

@onready var lvl_label = %LvlLabel

var displayed_lvl := 0.0
var displayed_exp := 0.0

func _ready():
	AuthManager.joined.connect(_on_join)
	
	EXP.exp_added.connect(_on_exp_added)
	
	EXP.goal_exp_set.connect(_on_goal_exp_set)
	EXP.exp_set.connect(_on_exp_set)
	EXP.lvl_set.connect(_on_lvl_set)

func _on_join():
	displayed_lvl = EXP.lvl
	displayed_exp = EXP.exp
	max_value = EXP.goal_exp
	value = EXP.exp
#

func _on_exp_added(exp_addition: int):
	displayed_exp += exp_addition
	

func _on_goal_exp_set(val: int): 
	max_value = val
func _on_exp_set(val: int):
	displayed_exp = val
func _on_lvl_set(val: int):
	displayed_lvl = val


func _process(delta):
	if max_value == 0:
		displayed_lvl = EXP.lvl
		displayed_exp = EXP.exp
		max_value = EXP.goal_exp
	value = lerp(value, displayed_exp, delta * 2)
	lvl_label.set_text(str(displayed_lvl))
	
	tooltip_text = str(roundi(displayed_exp)) + " / " + str(roundi(max_value))
	
	if displayed_lvl < 150 and value >= max_value:
		displayed_lvl += 1
		value = 0
		displayed_exp -= max_value
		max_value = roundi(max_value * 1.0474522)
		
		if displayed_lvl >= 149:
			max_value = 1000000
		if displayed_lvl == 150:
			displayed_exp = 1000000
