extends BulletHoming
class_name Rocket

func get_life_time() -> int: return 3000
func get_life_time_rng() -> int: return 1000

func get_hit_animation_type() -> String: return "explosion_small"
func get_hit_animation_quantity() -> int: return 1
func get_bullet_hit_args() -> Dictionary: return {
	"amount": 1,
	"velocity": Vector2(0, 50)
	}
