extends Camera3D

# --- Exported Variables ---
@export var orbit_target: Node3D = null  # The object to orbit around
@export var distance: float = 4.0        # Distance between the camera and the target
@export var zoom_speed: float = 1.0      # Speed of zooming in/out
@export var rotation_speed: float = 0.005  # Sensitivity of orbiting
@export var min_distance: float = 2.5    # Minimum zoom distance
@export var max_distance: float = 6.0    # Maximum zoom distance

# --- Internal State ---
var azimuth: float = 0.0    # Horizontal rotation angle
var elevation: float = 0.0  # Vertical rotation angle
var left_mouse_pressed: bool = false  # Tracks if left mouse button is held
var touch_events: Dictionary = {}  # Tracks touch events
var last_distance: float = 0.0  # Stores the previous distance between two fingers

func _ready() -> void:
	current = true  # Ensure this is the active camera
	if orbit_target == null:
		push_error("No orbit target assigned! Please assign a Node3D object to orbit around.")
		return

	# Calculate initial azimuth and elevation based on camera’s position
	var offset: Vector3 = global_transform.origin - orbit_target.global_transform.origin
	distance = offset.length()  # Ensure correct initial distance
	
	# Compute azimuth and elevation using spherical coordinates
	azimuth = atan2(offset.x, offset.z)
	elevation = atan2(-offset.y, sqrt(offset.x * offset.x + offset.z * offset.z))

	update_camera_position()  # Ensure camera starts at correct angle

func _process(delta: float) -> void:
	if orbit_target:
		update_camera_position()

func _input(event: InputEvent) -> void:
	# Handle Left Mouse Button Press/Release for PC
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_pressed = event.pressed

		# Zoom with Mouse Wheel (only when not dragging)
		if not left_mouse_pressed:  
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				distance -= zoom_speed
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				distance += zoom_speed
			distance = clamp(distance, min_distance, max_distance)
			update_camera_position()

	# Handle Mouse Motion for Rotation on PC
	if event is InputEventMouseMotion and left_mouse_pressed:
		var prev_elevation: float = elevation
		azimuth -= event.relative.x * rotation_speed
		elevation -= event.relative.y * rotation_speed

		# Clamp elevation to prevent unnatural angles
		elevation = clamp(elevation, -PI / 2 + 0.1, 0.0)

		# Prevent zooming-like effect when elevation is clamped
		if elevation == -PI / 2 + 0.1 or elevation == 0.0:
			elevation = prev_elevation

		update_camera_position()

	# Handle Touch Input for Zoom on Mobile
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_events[event.index] = event.position
		else:
			touch_events.erase(event.index)
			if touch_events.size() < 2:
				last_distance = 0.0  # Reset when fewer than 2 touches

	# Handle Pinch Zoom Gesture on Mobile
	if event is InputEventScreenDrag:
		touch_events[event.index] = event.position
		
		# Ensure exactly two fingers are touching
		if touch_events.size() == 2:
			var points: Array[Vector2] = touch_events.values()
			if points.size() < 2:
				return  # Prevent out-of-bounds errors

			# Calculate current distance between two fingers
			var current_distance: float = points[0].distance_to(points[1])

			# If last distance exists, adjust zoom
			if last_distance > 0.0:
				var delta: float = current_distance - last_distance
				adjust_zoom(delta)

			last_distance = current_distance  # Update last distance

func adjust_zoom(delta: float) -> void:
	# Adjust zoom based on pinch gesture (scaled for mobile)
	var direction: float = -delta * zoom_speed * 0.005  # Reduce effect on mobile
	distance += direction
	distance = clamp(distance, min_distance, max_distance)
	update_camera_position()  # Ensure camera updates instantly

func update_camera_position() -> void:
	# Calculate the new position using spherical coordinates
	var x: float = orbit_target.global_transform.origin.x + distance * cos(elevation) * sin(azimuth)
	var y: float = orbit_target.global_transform.origin.y - distance * sin(elevation)
	var z: float = orbit_target.global_transform.origin.z + distance * cos(elevation) * cos(azimuth)
	
	# Ensure camera doesn't go below target
	global_transform.origin = Vector3(x, max(y, orbit_target.global_transform.origin.y), z)
	
	# Look at the target object
	look_at(orbit_target.global_transform.origin)
