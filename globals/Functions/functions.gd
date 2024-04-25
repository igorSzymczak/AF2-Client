extends Node

func shorten_number(number: float) -> String:
	var abs_number = abs(number)
	var scale := ""
	
	if abs_number >= 1e9: # billion
		abs_number /= 1e9
		scale = " B"
	elif abs_number >= 1e6: # million
		abs_number /= 1e6
		scale = " M"
	elif abs_number >= 1e3: # thousand
		abs_number /= 1e3
		scale = " K"
	
	var shortened_number
	if !scale:
		shortened_number = round(abs_number)
	else:
		shortened_number = round_to_dec(abs_number, 2)
	var shortened_number_str = str(shortened_number)
	
	if "." in shortened_number_str:
		# Remove trailing zeros after dot
		shortened_number_str = shortened_number_str.rstrip("0").rstrip(".")
	
	var sign = ""
	if number < 0:
		sign = "-"
	
	return sign + shortened_number_str + scale

func round_to_dec(number: float, digit: int) -> float:
	return round(number * pow(10.0, digit)) / pow(10.0, digit)
