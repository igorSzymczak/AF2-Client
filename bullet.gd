extends Area2D
class_name Bullet

const SPEED := 1200
var direction := Vector2.ZERO

func _physics_process(delta: float) -> void:
	if direction != Vector2.ZERO:
		var vel = direction * SPEED * delta
		self.global_position += vel

func set_direction(dir: Vector2) -> void:
	self.direction = dir


func _on_lifetime_timeout() -> void:
	queue_free()
