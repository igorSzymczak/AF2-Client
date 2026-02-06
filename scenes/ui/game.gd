extends Control

@onready var chat = %Chat
@onready var safezone_label = %SafezoneLabel
@onready var center = %Center

var selected_animation = null
var animation_finished = true
var next_animation: String
func _process(_delta: float):
	var me: Player = g.me
	if (
		is_instance_valid(me) and 
		me.alive and 
		g.get_player_monitorable(AuthManager.my_user_id) and 
		me.landed_structure == null
	):
		safezone_label.hide()
	else: safezone_label.show()
	
	if next_animation and animation_finished:
		var player_landed = g.me and g.me.landed_structure != null
		if (
			(player_landed and next_animation == "open")
			or (!player_landed and next_animation == "close")
		):
			next_animation = ""
			return
		var anim_to_play = next_animation
		next_animation = ""
		print("executing next_animation: " + anim_to_play)
		select_animation(anim_to_play)

func select_animation(animation_name: String):
	if !animation_finished: 
		next_animation = animation_name
	if animation_finished:
		if animation_name == "open":
			animation_finished = false
			show()
			var scale_tween: Tween = create_tween()
			scale_tween.tween_property(self, "modulate:a", 1.0, 0.3)
			
			await get_tree().create_timer(0.3).timeout
			animation_finished = true
			
		elif animation_name == "close":
			animation_finished = false
			var scale_tween: Tween = create_tween()
			scale_tween.tween_property(self, "modulate:a", 0.0, 0.3)
			
			await get_tree().create_timer(0.3).timeout
			hide()
			animation_finished = true
