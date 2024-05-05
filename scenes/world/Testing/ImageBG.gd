extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

var me: Player
func _process(_delta):
	if !me:
		me = g.me
		return
	
	rect.size = get_viewport().size * (1.0 / me.camera.zoom.x)
