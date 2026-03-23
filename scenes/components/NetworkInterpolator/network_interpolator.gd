class_name NetworkInterpolator extends Node

# ile "w przeszlosc" renderujemy (sekundy)
@export var interpolation_delay: float = 0.05

# bufor stanow z serwera
var _buffer: Array = []

# struktura stanu:
# { time: float, pos: Vector2, rot: float }

func add_state(pos: Vector2, rot: float) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	
	_buffer.append({
		"time": now,
		"pos": pos,
		"rot": rot
	})
	
	# trzymamy tylko ostatnie ~1 sekundy danych
	while _buffer.size() > 2 and _buffer[1].time < now - 1.0:
		_buffer.pop_front()


func get_transform() -> Dictionary:
	if _buffer.size() == 0:
		return {}
	
	var render_time := Time.get_ticks_msec() / 1000.0 - interpolation_delay
	
	# znajdz dwa stany
	for i in range(_buffer.size() - 1):
		var a = _buffer[i]
		var b = _buffer[i + 1]
		
		if a.time <= render_time and render_time <= b.time:
			var t := inverse_lerp(a.time, b.time, render_time)
			
			return {
				"pos": a.pos.lerp(b.pos, t),
				"rot": lerp_angle(a.rot, b.rot, t)
			}
	
	# fallback – jak nie mamy dwoch punktow
	return {
		"pos": _buffer[-1].pos,
		"rot": _buffer[-1].rot
	}
