extends BetterInput

var last_text: String
var last_time := 0

func _input_ready():
	AuthManager.joined.connect(_on_join)

func _on_join() -> void:
	await get_tree().create_timer(0.1).timeout
	text = g.me.nickname

func _on_main_player_created(player: Player) -> void:
	text = player.nickname

func _input_process():
	var t: int = Time.get_ticks_msec()
	if t - 1000 > last_time and text != last_text and text.length() > 0 and g.Players.size() > 0:
		last_text = text
		last_time = t
		ChatManager.request_nickname_change.rpc_id(1, AuthManager.my_user_id, text)


func _on_focus_exited():
	g.can_perform_actions = true
	if text.length() == 0:
		text = last_text
