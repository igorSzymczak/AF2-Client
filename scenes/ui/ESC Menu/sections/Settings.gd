extends Control

@export var animation_index: int = 2

@onready var music_slider = %MusicVolumeSlider
@onready var effects_slider = %SFXVolumeSlider
@onready var interface_slider = %InterfaceVolumeSlider
@onready var ambience_slider = %AmbienceVolumeSlider
@onready var dma_checkbox = %DisableMouseAim
@onready var reticle_checkbox = %Reticle

var user_prefs: UserPreferences

func _ready():
	user_prefs = UserPreferences.load_or_create()
	if music_slider: music_slider.value = user_prefs.music_audio_level
	if effects_slider: effects_slider.value = user_prefs.effects_audio_level
	if interface_slider: interface_slider.value = user_prefs.interface_audio_level
	if ambience_slider: ambience_slider.value = user_prefs.ambience_audio_level
	
	if dma_checkbox: dma_checkbox.button_pressed = user_prefs.disable_mouse_aim
	if reticle_checkbox: reticle_checkbox.button_pressed = user_prefs.reticle
	

func _on_music_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_slider.bus_index, linear_to_db(value))
	if user_prefs:
		user_prefs.music_audio_level = value
		user_prefs.save()
	
func _on_sfx_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(effects_slider.bus_index, linear_to_db(value))
	if user_prefs:
		user_prefs.effects_audio_level = value
		user_prefs.save()

func _on_interface_volume_slider_value_changed(value):
	SoundManager.play_sound_from_name_locally("ButtonHover")
	AudioServer.set_bus_volume_db(interface_slider.bus_index, linear_to_db(value))
	if user_prefs:
		user_prefs.interface_audio_level = value
		user_prefs.save()

func _on_ambience_volume_slider_value_changed(value):
	AudioServer.set_bus_volume_db(ambience_slider.bus_index, linear_to_db(value))
	if user_prefs:
		user_prefs.ambience_audio_level = value
		user_prefs.save()

func _on_disable_mouse_aim_pressed():
	if user_prefs:
		user_prefs.disable_mouse_aim = !user_prefs.disable_mouse_aim
		user_prefs.save()


func _on_reticle_pressed():
	if user_prefs:
		user_prefs.reticle = !user_prefs.reticle
		user_prefs.save()
