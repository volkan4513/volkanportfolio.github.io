extends Camera3D

# Zoom limits and speed
var min_zoom_distance = 2.0
var max_zoom_distance = 20.0
var zoom_speed = 0.1

# Variables to track touch events
var touch_events = {}
var last_distance = 0.0

func _unhandled_input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_events[event.index] = event.position
		else:
			touch_events.erase(event.index)
			if touch_events.size() < 2:
				last_distance = 0.0  # Reset when fewer than 2 touches

	if event is InputEventScreenDrag:
		touch_events[event.index] = event.position
		if touch_events.size() == 2:
			# Get positions of both touch points
			var points = touch_events.values()
			var current_distance = points[0].distance_to(points[1])
			
			# If last distance is set, determine zoom direction
			if last_distance > 0.0:
				var delta = current_distance - last_distance
				adjust_zoom(delta)
			
			last_distance = current_distance

func adjust_zoom(delta):
	# Adjust zoom based on delta
	var direction = -delta * zoom_speed  # Negative delta zooms out, positive zooms in
	var new_position = position + global_transform.basis.z * direction
	var distance_to_origin = new_position.length()
	
	# Clamp the zoom distance
	if distance_to_origin >= min_zoom_distance and distance_to_origin <= max_zoom_distance:
		position = new_position
