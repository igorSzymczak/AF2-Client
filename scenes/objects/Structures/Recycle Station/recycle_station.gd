class_name RecycleStation extends Structure

@export var progress_bar: ProgressBar

func _ready() -> void:
	progress_bar.value = 0.0

func animate_progress_bar(value: float, seconds: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(progress_bar, "value", value, seconds)
