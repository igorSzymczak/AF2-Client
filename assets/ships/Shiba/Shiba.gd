extends ShipComponent

@onready var sprite: Sprite2D = $Sprite

func _process(delta):
	if global_rotation < - PI/2 or global_rotation > PI/2:
		sprite.scale = Vector2(1, -1)
	else:
		sprite.scale = Vector2(1, 1)
	
	if global_rotation > PI * 2: global_rotation -= PI * 2
