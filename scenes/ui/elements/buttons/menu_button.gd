extends Button

@export var hover_underline_effect := true
@onready var underline = $Underline
@onready var button_width = self.get_rect().size.x

var hovered = false
var currently_underlined = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	button_width = self.get_rect().size.x
	handle_hover(delta)


func _on_mouse_entered():
	hovered = true
	SoundManager.play_sound_from_name_locally("ButtonHover")
func _on_mouse_exited(): hovered = false
func _on_focus_entered(): hovered = true
func _on_focus_exited(): hovered = false

func handle_hover(delta: float):
	if !hover_underline_effect: return
	if hovered:
		underline.size = underline.size.lerp(Vector2(button_width, underline.size.y), delta * 9)
		underline.position.x = button_width/2.0 - underline.size.x/2.0
		currently_underlined = true
	elif !hovered and currently_underlined:
		underline.size = underline.size.lerp(Vector2(0, underline.size.y), delta * 3)
		underline.position.x = button_width/2.0 - underline.size.x/2.0
		if underline.size.x <= button_width * 0.01:
			underline.size.x = 0
			currently_underlined = false
	


