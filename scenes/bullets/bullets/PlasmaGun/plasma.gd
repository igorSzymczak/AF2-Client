extends Bullet
class_name Plasma

func get_life_time() -> int: return 1200
func get_life_time_rng() -> int: return 200

func get_hit_animation_type() -> String: return "bullet_regular"
func get_hit_animation_quantity() -> int: return 3
func get_bullet_hit_args() -> Dictionary: return {"color": Color(2, 194, 255), "scale": 1.4}
