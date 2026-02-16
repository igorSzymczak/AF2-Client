class_name Homerus extends CharacterBody2D

var gid: int # GameManager ID

@onready var engine = $Engine
@onready var left_segment = $LeftSegment
@onready var right_segment = $RightSegment

@onready var main_sprite = $Sprite
@onready var left_sprite = $LeftSegment/Sprite
@onready var right_sprite = $RightSegment/Sprite
@onready var poi: POI = $PoiComponent

var server_pos := Vector2.ZERO
var server_rot := 0.0
var server_engine_active := false
var server_left_segment_rot := 0.0
var server_right_segment_rot := 0.0

var server_health := 0
var last_health := 0
var server_shield := 0
var last_shield := 0

var homerus_alive := true
var main_segment_alive := true
var left_segment_alive := true
var right_segment_alive := true

var server_main_alive := true
var server_left_alive := true
var server_right_alive := true

func _process(delta):
	if HomerusManager.global_position != Vector2.ZERO:
		server_pos = HomerusManager.global_position
		server_rot = HomerusManager.rotation
		server_engine_active = HomerusManager.engine_active
		server_left_segment_rot = HomerusManager.left_segment_rotation
		server_right_segment_rot = HomerusManager.right_segment_rotation
		server_health = HomerusManager.health
		server_shield = HomerusManager.shield
		server_main_alive = HomerusManager.main_segment_alive
		server_left_alive = HomerusManager.left_segment_alive
		server_right_alive = HomerusManager.right_segment_alive
		
		if main_segment_alive and !server_main_alive:
			main_segment_alive = false
			handle_main_segment_death()
		if left_segment_alive and !server_left_alive:
			left_segment_alive = false
			handle_left_segment_death()
		if right_segment_alive and !server_right_alive:
			right_segment_alive = false
			handle_right_segment_death()
		if !server_main_alive and !server_left_alive and !server_right_alive and homerus_alive:
			homerus_alive = false
			handle_death()
		if !homerus_alive and server_main_alive and server_left_alive and server_right_alive:
			homerus_alive = true
			handle_revoke()
		
		if homerus_alive:
			global_position = global_position.lerp(server_pos, delta * 10)
			rotation = lerp_angle(rotation, server_rot, delta * 10)
			if !engine.active and server_engine_active: engine.activate_thruster()
			elif engine.active and !server_engine_active: engine.deactivate_thruster(Vector2.ZERO)
			
			left_segment.rotation = server_left_segment_rot
			right_segment.rotation = server_right_segment_rot
			
			if last_health != server_health:
				last_health = server_health
				GlobalSignals.boss_health.emit(server_health)
			
			if last_shield != server_shield:
				last_shield = server_shield
				GlobalSignals.boss_shield.emit(server_shield)
			
		#left_segment.rotation = lerp_angle(left_segment.rotation, server_left_segment_rot, delta * 10)
		#right_segment.rotation = lerp_angle(right_segment.rotation, server_right_segment_rot, delta * 10)
		

func handle_main_segment_death():
	GlobalSignals.create_explosion.emit(global_position, "explosion_large", 1, {})
	SoundManager.play_sound_from_name_locally("ActorDeath")
	
	var tween = create_tween()
	tween.tween_property(main_sprite, "modulate", Color(0.4 ,0.4 ,0.4 ,0.4), 0.5)

func handle_left_segment_death():
	GlobalSignals.create_explosion.emit(left_segment.global_position, "explosion_large", 1, {})
	SoundManager.play_sound_from_name_locally("ActorDeath")
	
	var tween = create_tween()
	tween.tween_property(left_sprite, "modulate", Color(0.4 ,0.4 ,0.4 ,0.4), 0.5)

func handle_right_segment_death():
	GlobalSignals.create_explosion.emit(right_segment.global_position, "explosion_large", 1, {})
	SoundManager.play_sound_from_name_locally("ActorDeath")
	
	var tween = create_tween()
	tween.tween_property(right_sprite, "modulate", Color(0.4 ,0.4 ,0.4 ,0.4), 0.5)


func handle_death():
	poi.visible = false
	GlobalSignals.create_explosion.emit(global_position, "explosion_huge", 1, {})
	await get_tree().create_timer(2).timeout
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(0.4 ,0.4 ,0.4 , 0), 0.3)

func handle_revoke():
	poi.visible = true
	main_segment_alive = true
	left_segment_alive = true
	right_segment_alive = true
	
	main_sprite.modulate = Color(1, 1, 1, 1)
	left_sprite.modulate = Color(1, 1, 1, 1)
	right_sprite.modulate = Color(1, 1, 1, 1)
	
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 1), 0.3)
	
	await get_tree().create_timer(0.5).timeout
