extends Bullet
class_name PiercingBullet

func get_life_time() -> int: return 1000
func get_life_time_rng() -> int: return 200

func get_hit_animation_type() -> String: return "bullet_regular"
func get_hit_animation_quantity() -> int: return 5
func get_bullet_hit_args() -> Dictionary: return {"color": Color(26, 184, 255), "scale": 2}
