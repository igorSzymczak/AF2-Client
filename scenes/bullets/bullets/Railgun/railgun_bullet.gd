extends Bullet
class_name RailgunBullet

func get_life_time() -> int: return 1300
func get_life_time_rng() -> int: return 100

func get_hit_animation_type() -> String: return "bullet_regular"
func get_hit_animation_quantity() -> int: return 3
func get_bullet_hit_args() -> Dictionary: return {"color": Color(247, 82, 111), "scale": 1.3}
