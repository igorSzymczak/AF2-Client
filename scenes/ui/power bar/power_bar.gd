extends Control
class_name PowerBar

@onready var B1: Polygon2D = $PowerBarFrame/Elements/B1
@onready var B2: Polygon2D = $PowerBarFrame/Elements/B2
@onready var B3: Polygon2D = $PowerBarFrame/Elements/B3
@onready var B4: Polygon2D = $PowerBarFrame/Elements/B4
@onready var B5: Polygon2D = $PowerBarFrame/Elements/B5
@onready var B6: Polygon2D = $PowerBarFrame/Elements/B6
@onready var B7: Polygon2D = $PowerBarFrame/Elements/B7
@onready var B8: Polygon2D = $PowerBarFrame/Elements/B8
@onready var B9: Polygon2D = $PowerBarFrame/Elements/B9
@onready var B10: Polygon2D = $PowerBarFrame/Elements/B10

@onready var hover_area: Area2D = $PowerBarFrame/HoverArea
@onready var label_container = $LabelContainer
@onready var label = $LabelContainer/MarginContainer/Label

@onready var weapon_panel_1 = %WeaponPanel1
@onready var weapon_panel_2 = %WeaponPanel2
@onready var weapon_panel_3 = %WeaponPanel3
@onready var weapon_panel_4 = %WeaponPanel4
@onready var weapon_panel_5 = %WeaponPanel5

@onready var weapon_tooltip: WeaponTooltip = %WeaponTooltip

@onready var weapon_frame = $WeaponFrame
@onready var weapon_frame_shader = $WeaponFrame/Noise
var default_weapon_frame_shader_pos_y: float

var weapon1: Weapon
var weapon2: Weapon
var weapon3: Weapon
var weapon4: Weapon
var weapon5: Weapon

func _ready() -> void:
	default_weapon_frame_shader_pos_y = weapon_frame_shader.position.y
	
	weapon_panel_1.mouse_entered.connect(show_weapon_tooltip.bind(1))
	weapon_panel_2.mouse_entered.connect(show_weapon_tooltip.bind(2))
	weapon_panel_3.mouse_entered.connect(show_weapon_tooltip.bind(3))
	weapon_panel_4.mouse_entered.connect(show_weapon_tooltip.bind(4))
	weapon_panel_5.mouse_entered.connect(show_weapon_tooltip.bind(5))
	
	weapon_panel_1.mouse_exited.connect(weapon_tooltip.hide)
	weapon_panel_2.mouse_exited.connect(weapon_tooltip.hide)
	weapon_panel_3.mouse_exited.connect(weapon_tooltip.hide)
	weapon_panel_4.mouse_exited.connect(weapon_tooltip.hide)
	weapon_panel_5.mouse_exited.connect(weapon_tooltip.hide)

func _process(_delta) -> void:
	if !g.PlayerInfo.is_empty():
		draw_bars()
		manage_weapon_change()
		weapon_frame_load()
	
func draw_bars() -> void:
	var total_percentage = (g.PlayerInfo.current_power / g.PlayerInfo.max_power) * 100
	
	var bars_filled = total_percentage / 10
	
	B1.modulate.a = (bars_filled - 0)
	B2.modulate.a = (bars_filled - 1)
	B3.modulate.a = (bars_filled - 2)
	B4.modulate.a = (bars_filled - 3)
	B5.modulate.a = (bars_filled - 4)
	B6.modulate.a = (bars_filled - 5)
	B7.modulate.a = (bars_filled - 6)
	B8.modulate.a = (bars_filled - 7)
	B9.modulate.a = (bars_filled - 8)
	B10.modulate.a = (bars_filled - 9)

var last_weapon_index = 1
func manage_weapon_change() -> void:
	if last_weapon_index != g.PlayerInfo.current_weapon:
		last_weapon_index = g.PlayerInfo.current_weapon
		var weapon_panel_size_halfed = weapon_panel_1.get_size() / 2.0
		if(last_weapon_index == 1): weapon_frame.position = weapon_panel_1.position + weapon_panel_size_halfed
		if(last_weapon_index == 2): weapon_frame.position = weapon_panel_2.position + weapon_panel_size_halfed
		if(last_weapon_index == 3): weapon_frame.position = weapon_panel_3.position + weapon_panel_size_halfed
		if(last_weapon_index == 4): weapon_frame.position = weapon_panel_4.position + weapon_panel_size_halfed
		if(last_weapon_index == 5): weapon_frame.position = weapon_panel_5.position + weapon_panel_size_halfed

func weapon_frame_load() -> void:
	var current_weapon = g.PlayerInfo.weapons[g.PlayerInfo.current_weapon]
	if current_weapon.shoot_delay > 200:
		var time_elapsed = float(Time.get_ticks_msec() - current_weapon.last_shot)
		var percentage = min(1, time_elapsed / float(current_weapon.shoot_delay))
		var weapon_panel_height = weapon_panel_1.get_size().y * 2.3
		
		var new_shader_y = default_weapon_frame_shader_pos_y + (weapon_panel_height * (1 - percentage))
		
		weapon_frame_shader.set_position(Vector2(weapon_frame_shader.position.x, new_shader_y))
	else:
		weapon_frame_shader.set_position(Vector2(weapon_frame_shader.position.x, default_weapon_frame_shader_pos_y))

func show_weapon_tooltip(index: int):
	if index < 1 or index > 5: return
	if g.PlayerInfo.is_empty(): return
	
	var weapon: Dictionary = g.PlayerInfo.weapons[index]
	var weapon_name: String = weapon.name
	var dmg: float = weapon.damage
	
	var weapon_element: Weapon = WeaponManager.get_weapon(weapon.type)
	
	var bullet_range: Array = weapon.bullet_amount
	var average_bullets: float = float(bullet_range[0] + bullet_range[1]) / 2.0
	
	var rps: float = 1000.0 / float(weapon.shoot_delay)
	
	var dps: float = rps * average_bullets * dmg
	
	weapon_tooltip.title.set_text(weapon_name)
	weapon_tooltip.dmg.set_text(Functions.shorten_number(dmg))
	weapon_tooltip.dps.set_text(Functions.shorten_number(dps))
	weapon_tooltip.description.set_text(weapon_element.description_short)
	
	weapon_tooltip.show()
