extends PathFollow3D

var speed : float = 0.5

func _process(delta: float) -> void:

	progress_ratio -= speed * delta

	if progress_ratio > 1.0:
		progress_ratio = 0  # Optional: you can reset to 0 for looping
