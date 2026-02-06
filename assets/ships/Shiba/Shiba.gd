extends ShipComponent

@onready var sprite: Sprite2D = $Sprite

func _process(_delta):
	if global_rotation < - PI/2 or global_rotation > PI/2:
		scale = Vector2(1, -1)
	else:
		scale = Vector2(1, 1)
	
	if global_rotation > PI * 2: global_rotation -= PI * 2
