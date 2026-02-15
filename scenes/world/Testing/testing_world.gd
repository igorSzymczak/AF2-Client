extends Node2D

@onready var bullet_manager: Node2D = $BulletManager
var structures: Array[Structure]

func get_structure(structure_name: String) -> Structure:
	for structure: Structure in structures:
		if structure.structure_name == structure_name:
			return structure
	push_warning("Structure not found: ", structure_name)
	return null
