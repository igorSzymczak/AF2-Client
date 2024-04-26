class_name WeaponTooltip extends PanelContainer

@onready var title: Label = %Title
@onready var dmg: Label = %dmg
@onready var dps: Label = %dps
@onready var description: Label = %Description
@onready var separator: HSeparator = %HSeparator

func _on_visibility_changed():
	if description.text.is_empty():
		separator.hide()
		description.hide()
	else:
		separator.show()
		description.show()
