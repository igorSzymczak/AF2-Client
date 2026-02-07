extends Node

var is_logged_in := false
var my_username: String
var my_user_id: int

var version := "Beta 3.0"
var latest_version: String


signal joined()
signal logged_in()
func handle_login(server_username):
	is_logged_in = true
	my_username = server_username
	logged_in.emit()

signal version_updated
func update_latest_version(ver: String):
	latest_version = ver
	
	version_updated.emit()
	

func try_register(_client_id: int, _username: String, _password: String): pass # Only Server
func try_login(_client_id: int, _username: String, _password: String): pass # Only Server
func _send_latest_version(_client_id: int): pass # Only Server

signal error(code: int)
@rpc("authority", "call_remote", "reliable")
func throw_error(code: int):
	error.emit(code)

signal success(code: int)
@rpc("authority", "call_remote", "reliable")
func throw_success(code: int):
	success.emit(code)

@rpc("any_peer", "call_remote", "reliable")
func request_register(username: String, password: String):
	print("Requested to register " + username)
	try_register(multiplayer.get_remote_sender_id(), username, password)

@rpc("any_peer", "call_remote", "reliable")
func request_login(username: String, password: String):
	print("Requested to login " + username)
	try_login(multiplayer.get_remote_sender_id(), username, password)

@rpc("authority", "call_remote", "reliable")
func log_in_user(server_username: String):
	handle_login(server_username) # Only Client

@rpc("any_peer", "call_remote", "reliable")
func request_latest_version():
	_send_latest_version(multiplayer.get_remote_sender_id())

@rpc("authority", "call_remote", "reliable")
func send_latest_version(ver: String):
	update_latest_version(ver)
