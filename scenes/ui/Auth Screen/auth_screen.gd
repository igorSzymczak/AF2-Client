extends Control

const USERNAME_MIN_LENGTH := 3
const USERNAME_MAX_LENGTH := 15

const PASSWORD_MIN_LENGTH := 8
const PASSWORD_MAX_LENGTH := 32
const PASSWORD_MIN_DIGITS := 1
const PASSWORD_MIN_LETTERS := 1
const PASSWORD_MIN_SPECIAL := 1


@onready var register_screen: Panel = %RegisterScreen
@onready var register_username: LineEdit = %RegisterUsername
@onready var register_password: LineEdit = %RegisterPassword
@onready var register_password_rep: LineEdit = %RegisterPasswordRepeat
@onready var register_button: Button = %RegisterButton
@onready var switch_to_login: Button = %SwitchToLogin

@onready var login_screen: Panel = %LoginScreen
@onready var login_username: LineEdit = %LoginUsername
@onready var login_password: LineEdit = %LoginPassword
@onready var login_button: Button = %LoginButton
@onready var switch_to_register: Button = %SwitchToRegister

@onready var error_label: Label = %ErrorLabel
@onready var success_label: Label = %SuccessLabel

var default_screen = "register"
var user_prefs: UserPreferences
func _ready():
	user_prefs = UserPreferences.load_or_create()
	if user_prefs and !user_prefs.last_username.is_empty():
		default_screen = "login"
	
	error_label.hide()
	success_label.hide()
	if default_screen == "login":
		_switch_to_login()
	else:
		_switch_to_register()
	
	var last_username: String
	
	if user_prefs and user_prefs.last_username:
		last_username = user_prefs.last_username
	
	if !last_username.is_empty():
		login_username.set_text(last_username)
	
	# Hiding Messages on Text Change
	register_username.text_changed.connect(hide_messages)
	register_password.text_changed.connect(hide_messages)
	register_password_rep.text_changed.connect(hide_messages)
	login_username.text_changed.connect(hide_messages)
	login_password.text_changed.connect(hide_messages)
	
	# Submiting on Enter
	register_username.text_submitted.connect(_handle_register_enter)
	register_password.text_submitted.connect(_handle_register_enter)
	register_password_rep.text_submitted.connect(_handle_register_enter)
	register_button.pressed.connect(submit_register)
	
	login_username.text_submitted.connect(_handle_login_enter)
	login_password.text_submitted.connect(_handle_login_enter)
	login_button.pressed.connect(submit_login)
	
	switch_to_login.pressed.connect(_switch_to_login)
	switch_to_register.pressed.connect(_switch_to_register)
	
	AuthManager.error.connect(throw_error)
	AuthManager.success.connect(throw_success)
	AuthManager.logged_in.connect(_handle_logged_in)
	
	if !last_username.is_empty():
		login_password.grab_focus.call_deferred()
		await get_tree().create_timer(0.2).timeout
		login_password.grab_focus.call_deferred()

#func _process(_delta):
	#login_password.grab_focus()

func _handle_logged_in():
	if user_prefs:
		user_prefs.last_username = AuthManager.my_username
		user_prefs.save()

func hide_messages(_ignored):
	error_label.hide()
	success_label.hide()

func _switch_to_login():
	register_screen.hide()
	login_screen.show()
	print("Switched to Login Screen")
	if user_prefs and !user_prefs.last_username.is_empty():
		login_password.grab_focus()
	else:
		login_username.grab_focus()
	

func _switch_to_register():
	login_screen.hide()
	register_screen.show()
	print("Switched to Register Screen")
	register_username.grab_focus()
	

func _handle_register_enter(_ignored): submit_register()

var registered_username
func submit_register():
	var provided_username = register_username.text
	var provided_password = register_password.text
	var provided_password_rep = register_password_rep.text
	
	var password_regex_data: Dictionary = get_regex_data(provided_password)
	
	if provided_username.length() < USERNAME_MIN_LENGTH:
		throw_error(001) ## Short Name
	elif provided_username.length() > USERNAME_MAX_LENGTH:
		throw_error(002) ## Long Name
	elif !provided_username.is_valid_identifier():
		throw_error(003) ## Weird Name
	elif provided_username == provided_password:
		throw_error(005) ## Name == Pass
	elif provided_password.length() < PASSWORD_MIN_LENGTH:
		throw_error(006) ## Short Pass
	elif provided_password.length() > PASSWORD_MAX_LENGTH:
		throw_error(007) ## Long Pass
	elif password_regex_data.digits < PASSWORD_MIN_DIGITS:
		throw_error(008) ## Not Enough Digits
	elif password_regex_data.letters < PASSWORD_MIN_LETTERS:
		throw_error(009) ## Not Enough Letters
	elif password_regex_data.special < PASSWORD_MIN_SPECIAL:
		throw_error(010) ## Not Enough Special
	elif provided_password != provided_password_rep:
		throw_error(011) ## Password1 is not Password2
	else:
		registered_username = provided_username
		var username = provided_username
		var password = provided_password
		AuthManager.request_register.rpc_id(1, username, password)

func _handle_login_enter(_ignored): submit_login()

func submit_login():
	var provided_username = login_username.text
	var provided_password = login_password.text
	if provided_username.length() < 1 or provided_password.length() < 1:
		throw_error(101) ## Name or Pass not Specified
	else:
		var username = provided_username
		var password = provided_password
		AuthManager.request_login.rpc_id(1, username, password)

func throw_error(code: int):
	success_label.hide()
	error_label.show()
	var message = "n/a"
		
		## Registering
		
	if   code == 001: message = "Registration Fail: Username must be at least " + str(USERNAME_MIN_LENGTH) + " Characters long."
	elif code == 002: message = "Registration Fail: Username must be at most " + str(USERNAME_MAX_LENGTH) + " Characters long."
	elif code == 003: message = "Registration Fail: Username allows only Digits, Letters a-Z, and _. Also Don't start the Username with a digit."
	elif code == 004: message = "Registration Fail: Username is Taken Already."
	elif code == 005: message = "Registration Fail: Password can Not be the Same as Username "
	elif code == 006: message = "Registration Fail: Password must be at least " + str(PASSWORD_MIN_LENGTH) + " Characters long."
	elif code == 007: message = "Registration Fail: Password must be at most " + str(PASSWORD_MAX_LENGTH) + " Characters long."
	elif code == 008: message = "Registration Fail: Password must have at least 1 Number."
	elif code == 009: message = "Registration Fail: Password must have at least 1 Letter."
	elif code == 010: message = "Registration Fail: Password must have at least 1 Special Character."
	elif code == 011: message = "Registration Fail: Repeated Password Does Not Match"
	#elif code == 002: message = "Failed to create an Account: Password must be minimum " + str(PASSWORD_MIN_LENGTH) + " Characters long."
	#elif code == 003: message = "Failed to create an Account: Password Can not be the same as Username. "
	#elif code == 004: message = "Failed to create an Account: Passwords don't match."
	#elif code == 005: message = "Failed to create an Account: This Username is Already Taken."
	#elif code == 006: message = "Failed to create an Account: This Username is Already Taken."
	#elif code == 007: message = "Failed to create an Account: This Username is Already Taken."
	#elif code == 008: message = "Failed to create an Account: This Username is Already Taken."
	#elif code == 009: message = "Failed to create an Account: This Username is Already Taken."
	#elif code == 0010: message = "Failed to create an Account: This Username is Already Taken."
	#elif code == 0011: message = "Failed to create an Account: This Username is Already Taken."
		
		## Logging In
		
	elif code == 101: message = "Failed to Log In: Please Fill in all Fields"
	elif code == 102: message = "Failed to Log In: Username doesn't exist."
	elif code == 103: message = "Failed to Log In: Wrong Password."
	elif code == 104: message = "Failed to Log In: You are already Connected to the Server. If that's not you, please contact @zlotyyy on Discord"
	elif code == 999: message = "Something weird happened, Please contact zlotyyy on Discord "
	print("Auth Error: " + message)
	error_label.set_text(message)

func throw_success(code: int):
	
	var message = "n/a"
	if code == 0:
		message = "Successfully Created an Account. Please Log In."
		register_username.clear()
		register_password.clear()
		register_password_rep.clear()
		# User created a account, set default login and switch to login screen
		login_username.set_text(registered_username)
		if user_prefs:
			user_prefs.last_username = registered_username
			user_prefs.save()
		
		_switch_to_login()
		
	elif code == 1:
		message = "Logged In Successfully!"
		login_username.clear()
		login_password.clear()
	
	await get_tree().create_timer(0.01).timeout
	error_label.hide()
	success_label.show()
	print("Auth Success: " + message)
	success_label.set_text(message)

func get_regex_data(text: String) -> Dictionary:
	var regex = RegEx.new()
	var alphabet_pattern = "[a-zA-Z]"
	var digit_pattern = "\\d"
	var special_pattern = "[^a-zA-Z\\d]"
	
	regex.compile(alphabet_pattern)
	var alphabet_matches = regex.search_all(text)
	
	regex.compile(digit_pattern)
	var digit_matches = regex.search_all(text)
	
	regex.compile(special_pattern)
	var special_matches = regex.search_all(text)
	
	var regex_data = {
		"digits": digit_matches.size(),
		"letters": alphabet_matches.size(),
		"special": special_matches.size()
	}
	
	return regex_data
