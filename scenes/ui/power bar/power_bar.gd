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

@onready var weapon_panel_1 = $WeaponPanel1
@onready var weapon_panel_2 = $WeaponPanel2
@onready var weapon_panel_3 = $WeaponPanel3
@onready var weapon_panel_4 = $WeaponPanel4
@onready var weapon_panel_5 = $WeaponPanel5

@onready var weapon_frame = $WeaponFrame
@onready var weapon_frame_shader = $WeaponFrame/Noise
var default_weapon_frame_shader_pos_y: float

func _ready() -> void:
	default_weapon_frame_shader_pos_y = weapon_frame_shader.position.y

func _process(_delta) -> void:
	if !GameManager.PlayerInfo.is_empty():
		draw_bars()
		manage_weapon_change()
		weapon_frame_load()
	
func draw_bars() -> void:
	var total_percentage = (GameManager.PlayerInfo.current_power / GameManager.PlayerInfo.max_power) * 100
	
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
	if last_weapon_index != GameManager.PlayerInfo.current_weapon:
		last_weapon_index = GameManager.PlayerInfo.current_weapon
		var weapon_panel_size_halfed = weapon_panel_1.get_size() / 2.0
		if(last_weapon_index == 1): weapon_frame.position = weapon_panel_1.position + weapon_panel_size_halfed
		if(last_weapon_index == 2): weapon_frame.position = weapon_panel_2.position + weapon_panel_size_halfed
		if(last_weapon_index == 3): weapon_frame.position = weapon_panel_3.position + weapon_panel_size_halfed
		if(last_weapon_index == 4): weapon_frame.position = weapon_panel_4.position + weapon_panel_size_halfed
		if(last_weapon_index == 5): weapon_frame.position = weapon_panel_5.position + weapon_panel_size_halfed

func weapon_frame_load() -> void:
	var current_weapon = GameManager.PlayerInfo.weapons[GameManager.PlayerInfo.current_weapon]
	if current_weapon.shoot_delay > 200:
		var time_elapsed = float(Time.get_ticks_msec() - current_weapon.last_shot)
		var percentage = min(1, time_elapsed / float(current_weapon.shoot_delay))
		var weapon_panel_height = weapon_panel_1.get_size().y * 2.3
		
		var new_shader_y = default_weapon_frame_shader_pos_y + (weapon_panel_height * (1 - percentage))
		
		weapon_frame_shader.set_position(Vector2(weapon_frame_shader.position.x, new_shader_y))
	else:
		weapon_frame_shader.set_position(Vector2(weapon_frame_shader.position.x, default_weapon_frame_shader_pos_y))

func _on_hover_area_mouse_entered(_body):
	push_error("display power NOW")
	label_container.position = get_local_mouse_position()
	label.text = "Power: " + str(GameManager.PlayerInfo.current_power) + " / " + str(GameManager.PlayerInfo.max_power)
