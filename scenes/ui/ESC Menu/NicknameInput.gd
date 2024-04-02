extends BetterInput

var last_text: String
var last_time := 0

#var user_prefs: UserPreferences
func _input_ready():
	pass
	#user_prefs = UserPreferences.load_or_create()
	#if user_prefs.nickname.length() > 0 and user_prefs.nickname.length() <= max_length:
		#text = user_prefs.nickname
		#GameManager.emit_signal("player_nickname", text)

func _input_process():
	var t = Time.get_ticks_msec()
	if t - 1000 > last_time and text != last_text and text.length() > 0 and GameManager.Players.size() > 0:
		last_text = text
		last_time = t
		ChatManager.request_nickname_change.rpc_id(1, AuthManager.my_username, text)


func _on_focus_exited():
	GameManager.can_perform_actions = true
	if text.length() == 0:
		text = last_text
