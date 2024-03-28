extends Bullet
class_name SpawnerLaser

func get_life_time() -> int: return 1000

func get_hit_animation_type() -> String: return "bullet_regular"
func get_hit_animation_quantity() -> int: return 2
func get_bullet_hit_args() -> Dictionary: return {"color": Color(29, 246, 246), "scale": 0.8}
