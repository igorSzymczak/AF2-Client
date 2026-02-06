class_name EnergyBlastExplosion extends ShockWave

	
func _process(delta: float) -> void:
	global_scale += Vector2(1.0, 1.0) * speed * delta
	time_of_living += delta
	sprite.material.set("shader_parameter/alpha", clamp(time_to_vanish / time_of_living - 1, 0.0, 1.0))
	
	if time_of_living > time_to_vanish:
		call_deferred("queue_free")
