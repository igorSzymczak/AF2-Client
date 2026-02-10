extends Node
class_name ExplosionManager

func _ready() -> void:
	GlobalSignals.connect("create_explosion", create_explosion)
	
#var last = Time.get_ticks_msec()
#func _physics_process(_delta) -> void:
	#
	#if Time.get_ticks_msec() - 100 > last:
		#last = Time.get_ticks_msec()
		#create_explosion(Vector2(1000, 1000), "bullet_small")
	
func create_explosion(pos: Vector2, type: String, quantity: int, args: Dictionary) -> void:
	var explosion_scene: PackedScene
	if type == "bullet_regular":
		explosion_scene = preload("res://globals/ExplosionManager/explosions/bullet_regular.tscn")
	elif type == "blocky":
		explosion_scene = preload("res://globals/ExplosionManager/explosions/blocky/blocky.tscn")
	elif type == "explosion_small":
		explosion_scene = preload("res://globals/ExplosionManager/explosions/explosion_small/explosion_small.tscn")
	elif type == "explosion_medium":
		explosion_scene = preload("res://globals/ExplosionManager/explosions/explosion_medium/explosion_medium.tscn")
	elif type == "explosion_large":
		explosion_scene = preload("res://globals/ExplosionManager/explosions/explosion_large/explosion_large.tscn")
	elif type == "explosion_huge":
		explosion_scene = preload("res://globals/ExplosionManager/explosions/explosion_huge/explosion_huge.tscn")
	
	elif !explosion_scene: 
		push_error("Not existant Explosion Type: '" + str(type) + "'")
		return
	
	if explosion_scene:
		for i in range(0, quantity):
			var explosion = explosion_scene.instantiate()
			if explosion.has_method("set_args"):
				explosion.set_args(args)
			explosion.global_position = pos
			add_child(explosion)
		
