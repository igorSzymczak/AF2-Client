extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

var local_player: Player
func _process(_delta):
	if !local_player:
		local_player = GameManager.local_player
		return
	
	rect.size = get_viewport().size * (1.0 / local_player.camera.zoom.x)
