extends Sprite2D

var elapsed_time := 0
@onready var player = $"../Player"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = player.position
	material.set_shader_parameter("time", elapsed_time)
	material.set_shader_parameter("mouse", player.position/10000.0)
	elapsed_time += delta
