extends Node

# Called when Client hits Enter to Send Message
func send_message(message: String):
	var user_id: int = AuthManager.my_user_id
	process_message_by_server.rpc_id(1, user_id, message)

func process_message(_user_id: int, _message: String):
	pass # Only server

@rpc("any_peer", "call_remote", "reliable")
func process_message_by_server(user_id: int, message: String):
	process_message(user_id, message)

signal received_message(message: String)
@rpc("authority", "call_remote", "reliable")
func display_message(message: String):
	received_message.emit(message)

signal nickname_changed(nickname: String)
@rpc("any_peer", "call_remote", "reliable")
func request_nickname_change(user_id: int, nickname: String):
	try_nickname_change(user_id, nickname)


func try_nickname_change(_user_id: int, _nickname: String):
	pass # Only Server
