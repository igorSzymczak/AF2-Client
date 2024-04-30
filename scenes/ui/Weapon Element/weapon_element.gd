class_name WeaponElement extends Control

var weapon_name: String : set = set_weapon_name
var lvl : int = 0 : set = set_lvl
var icon_texture: Texture2D : set = set_icon_texture
var info_shown: bool = true : set = set_info_shown

var weapon: Weapon
var rng = RandomNumberGenerator.new()
var icon_color: Color : set = set_icon_color

@onready var icon_rect: TextureRect = %Icon
@onready var icon_label: Label = %IconLabel
@onready var icon_color_rect: ColorRect = %IconColor
@onready var info_container: Control = %InfoContainer
@onready var name_label: Label = %NameLabel
@onready var lvl_label: Label = %LvlLabel
@onready var button: Button = %Button

func _ready():
	icon_color = Color(rng.randf_range(0.2, 0.6), rng.randf_range(0.2, 0.6), rng.randf_range(0.2, 0.6))

func set_icon_color(value: Color):
	icon_color = value
	icon_color_rect.color = icon_color

func set_weapon_name(value: String):
	weapon_name = value
	name_label.text = weapon_name
	if weapon_name.length() >= 2:
		icon_label.text = weapon_name.left(2).to_upper()

func set_lvl(value: int):
	lvl_label.set_text("lvl " + str(value))
	if value == 0:
		lvl_label.hide()
	else:
		lvl_label.show()

func set_icon_texture(value: Texture2D):
	icon_rect.texture = value

func set_info_shown(shown: bool):
	info_shown = shown
	
	if shown:
		info_container.show()
	else:
		info_container.hide()
		
	
