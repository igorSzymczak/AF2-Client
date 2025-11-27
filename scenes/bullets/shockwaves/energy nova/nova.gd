extends ShockWave

func _process(delta: float) -> void:
	scale += Vector2(1.0, 1.0) * speed * delta
	time_of_living += delta
	
	time_to_vanish = 0.5
	
	sprite.material.set("shader_parameter/alpha", pow(clamp((time_to_vanish / time_of_living) - 1.0, 0.0, 0.8), 2))
	
	if time_of_living > time_to_vanish:
		call_deferred("queue_free")
