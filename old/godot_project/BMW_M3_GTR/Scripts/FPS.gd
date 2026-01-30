extends Control

func _process(delta: float) -> void:
	# Retrieve performance stats
	var fps: int = Engine.get_frames_per_second()

	# Update the label text with the stats
	$Label.text = "FPS: %d\n" % fps
