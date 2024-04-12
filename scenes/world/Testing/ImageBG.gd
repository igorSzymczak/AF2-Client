extends CanvasLayer

var local_player: Player
func _process(_delta):
	if !local_player and GameManager.local_player:
		local_player = GameManager.local_player
	
	if local_player:
		offset = local_player.global_position
