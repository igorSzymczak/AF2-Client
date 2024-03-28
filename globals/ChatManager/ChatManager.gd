extends Node

# Called when Client hits Enter to Send Message
func send_message(message: String):
	var username: String = AuthManager.my_username
	process_message_by_server.rpc_id(1, username, message)

func process_message(_username: String, _message: String):
	pass # Only server

@rpc("any_peer", "call_remote", "reliable")
func process_message_by_server(username: String, message: String):
	process_message(username, message)

signal received_message(message: String)
@rpc("authority", "call_remote", "reliable")
func broadcast_message(message: String):
	received_message.emit(message)

