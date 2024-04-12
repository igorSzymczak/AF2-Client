extends Control

@export var SEND_INTERVAL: int = 1000
@export var MAX_MESSAGES: int = 40

@onready var messages_container = %MessagesContainer
@onready var message_input = %MessageInput
@onready var scroll_container = %ScrollContainer
@onready var scrollbar: VScrollBar = scroll_container.get_v_scroll_bar()
@onready var default_placeholder: String = message_input.placeholder_text

var max_scroll
func _ready():
	ChatManager.received_message.connect(create_message)
	scrollbar.changed.connect(scroll_to_bottom)
	max_scroll = scrollbar.max_value


func scroll_to_bottom():
	if max_scroll != scrollbar.max_value:
		max_scroll = scrollbar.max_value
		scroll_container.scroll_vertical = scrollbar.max_value

func remove_overflow():
	if is_instance_valid(messages_container):
		var message_count = messages_container.get_child_count()
		if message_count > MAX_MESSAGES:
			messages_container.get_child(0).queue_free()

var last_sent_time := 0
func _on_message_input_text_submitted(new_text):
	var t = Time.get_ticks_msec()
	if t - SEND_INTERVAL < last_sent_time or new_text.length() < 1:
		message_input.add_theme_color_override("font_color", Color(1.0, 0.24, 0.24))
		message_input.add_theme_color_override("font_placeholder_color", Color(1.0, 0.24, 0.24, 0.6))
		message_input.placeholder_text = " pls do not spam!"
		
		await get_tree().create_timer(0.5).timeout
		
		message_input.remove_theme_color_override("font_color")
		message_input.remove_theme_color_override("font_placeholder_color")
		message_input.placeholder_text = default_placeholder
	else:
		# Message Sent to Server
		last_sent_time = t
		message_input.release_focus.call_deferred()
		ChatManager.send_message(new_text)
		message_input.clear()
		message_input.remove_theme_color_override("font_color")
		message_input.add_theme_color_override("font_placeholder_color", Color(0.24, 1.0, 0.24, 0.6))
		message_input.placeholder_text = " Sent!"
		await get_tree().create_timer(1.0).timeout
		message_input.remove_theme_color_override("font_placeholder_color")
		message_input.placeholder_text = default_placeholder

func create_message(message: String):
	var label = preload("res://scenes/ui/Chat/messages/message.tscn").instantiate()
	label.text = message
	messages_container.add_child(label)
	
	remove_overflow()
