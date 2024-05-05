class_name BetterInput extends LineEdit

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	
	_input_ready()

func _input_ready(): pass

func _process(_delta):
	if has_focus() and !mouse_in and Input.is_action_just_pressed("LMB"):
		self.release_focus()
	
	_input_process()
func _input_process(): pass

var mouse_in = false
func _on_mouse_entered(): self.mouse_in = true
func _on_mouse_exited(): self.mouse_in = false

func _on_focus_entered(): g.can_perform_actions = false
func _on_focus_exited(): g.can_perform_actions = true
