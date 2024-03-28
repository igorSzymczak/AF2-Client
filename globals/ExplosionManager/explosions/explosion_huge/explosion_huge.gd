extends GPUParticles2D

func _ready() -> void:
	emitting = true;
	SoundManager.play_sound_from_name_locally("HomerusDeath")

func _on_finished():
	queue_free()
