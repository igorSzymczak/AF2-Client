extends Bullet

func get_life_time() -> int: return 3000
func get_life_time_rng() -> int: return 50

func get_hit_animation_type() -> String: return "bullet_regular"
func get_hit_animation_quantity() -> int: return 1
func get_bullet_hit_args() -> Dictionary: return {"color": Color(2, 194, 255), "scale": 2.0}

func special_ready() -> void:
	sprite.material = sprite.material.duplicate(true)
	sprite.material.set("shader_parameter/wave_amp", 2.0)
	sprite.material.set("shader_parameter/wave_freq", 1.0)
	sprite.material.set("shader_parameter/wave_speed", 5.0)
	
