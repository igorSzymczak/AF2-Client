extends CanvasLayer

@onready var rect: ColorRect = %JustBlack

func _process(_delta):
	if !g.me:
		return
	rect.size = get_viewport().size * (1.0 / g.me.camera.zoom.x)
