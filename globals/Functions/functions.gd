extends Node

func shorten_number(number: float) -> String:
	var abs_number: float = abs(number)
	var scale: String = ""
	
	if abs_number >= 1e9: # billion
		abs_number /= 1e9
		scale = " B"
	elif abs_number >= 1e6: # million
		abs_number /= 1e6
		scale = " M"
	elif abs_number >= 1e3: # thousand
		abs_number /= 1e3
		scale = " K"
	
	var shortened_number: float
	if !scale:
		shortened_number = round(abs_number)
	else:
		shortened_number = round_to_dec(abs_number, 2)
	var shortened_number_str: String = str(shortened_number)
	
	if "." in shortened_number_str:
		# Remove trailing zeros after dot
		shortened_number_str = shortened_number_str.rstrip("0").rstrip(".")
	
	var sign_symbol = ""
	if number < 0:
		sign_symbol = "-"
	
	return sign_symbol + shortened_number_str + scale

func round_to_dec(number: float, digit: int) -> float:
	return round(number * pow(10.0, digit)) / pow(10.0, digit)

func rotate_point_around_center(point: Vector2, center: Vector2, angle: float) -> Vector2:
	var difference: Vector2 = point - center
	var sin_theta: float = sin(angle)
	var cos_theta: float = cos(angle)

	var rotated_x: float = difference.x * cos_theta - difference.y * sin_theta
	var rotated_y: float = difference.x * sin_theta + difference.y * cos_theta

	return center + Vector2(rotated_x, rotated_y)

func calculate_point_distanced_by_angle(A: Vector2, angle_B: float, distance_C: float) -> Vector2:
	var D: Vector2 = Vector2(
		A.x + distance_C * cos(angle_B),
		A.y + distance_C * sin(angle_B)
	)
	return D

func make_arc(radius: float, angle: float, steps: int = 32) -> PackedVector2Array:
	var pts: PackedVector2Array = []
	var half = angle / 2.0
	pts.append(Vector2.ZERO)

	for i in range(steps + 1):
		var t = i / float(steps)
		var ang = -half + t * (2.0 * half)
		pts.append(Vector2(cos(ang), sin(ang)) * radius)

	return pts
