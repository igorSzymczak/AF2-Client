class_name ShockWave extends Area2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionPolygon2D = $CollisionPolygon2D

# operating Stuff
var time_of_living: float = 0.0;
@export var shockwave_type: WeaponManager.ShockwaveType
@export var angle: float = 2 * PI
@export var speed: float = 100
@export var time_to_vanish: float = 1.0

func _ready() -> void:
	sprite.material = sprite.material.duplicate()
	
	var arc: PackedVector2Array = Functions.make_arc(10, angle, 32)
	collision.polygon = arc;
	sprite.material.set("shader_parameter/angle_from", - angle/2.0)
	sprite.material.set("shader_parameter/angle_to", angle/2.0)
	
	print("shockwave timeToVanish: ", time_to_vanish)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	scale += Vector2(1.0, 1.0) * speed * delta
	time_of_living += delta
	sprite.material.set("shader_parameter/radius_inner", time_of_living / time_to_vanish)
	
	
	if time_of_living > time_to_vanish:
		call_deferred("queue_free")
