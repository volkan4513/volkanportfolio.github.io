extends Camera3D

# --- Exported Variables ---
@export var orbit_target: Node3D = null  # The object to orbit around
@export var rotation_speed: float = 0.005  # Sensitivity of orbiting
@export var zoom_speed: float = 1.0  # Speed of zooming
@export var min_zoom_distance: float = 2.0  # Minimum zoom distance
@export var max_zoom_distance: float = 20.0  # Maximum zoom distance

# --- Internal State ---
var azimuth: float = 0.0    # Horizontal rotation angle
var elevation: float = 0.0  # Vertical rotation angle
var left_mouse_pressed: bool = false  # Tracks if left mouse button is held
var touch_events: Dictionary = {}  # Tracks touch events
var zoom_distance: float = 10.0  # Initial zoom distance
var last_touch_distance: float = 0.0  # Distance between two touch points

func _ready() -> void:
	current = true  # Ensure this is the active camera
	if orbit_target == null:
		push_error("No orbit target assigned! Please assign a Node3D object to orbit around.")
		return

	# Calculate initial azimuth and elevation based on camera’s position
	var offset: Vector3 = global_transform.origin - orbit_target.global_transform.origin
	
	# Compute azimuth and elevation using spherical coordinates
	azimuth = atan2(offset.x, offset.z)
	elevation = atan2(-offset.y, sqrt(offset.x * offset.x + offset.z * offset.z))

	# Initialize zoom distance
	zoom_distance = offset.length()

	update_camera_position()  # Ensure camera starts at correct angle

func _process(delta: float) -> void:
	if orbit_target:
		update_camera_position()

func _input(event: InputEvent) -> void:
	# Handle Left Mouse Button Press/Release for PC (mouse input)
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_pressed = event.pressed

	# Handle Mouse Motion for Rotation on PC (mouse input)
	if event is InputEventMouseMotion and left_mouse_pressed:
		var prev_elevation: float = elevation
		azimuth -= event.relative.x * rotation_speed
		elevation -= event.relative.y * rotation_speed

		# Clamp elevation to prevent unnatural angles
		elevation = clamp(elevation, -PI / 2 + 0.1, 0.0)

		# Prevent issues when elevation is clamped
		if elevation == -PI / 2 + 0.1 or elevation == 0.0:
			elevation = prev_elevation

	# Handle Touch Input (Pinch-to-Zoom for Android)
	if event is InputEventScreenTouch:
		if event.touch_index == 0:
			if event.pressed:
				# Store the initial touch position
				touch_events[event.touch_index] = event.position
			else:
				touch_events.erase(event.touch_index)

	# Handle Pinch-to-Zoom Gesture (Multiple Touches for Android)
	if event is InputEventScreenDrag and event.touch_index == 0 and touch_events.size() > 1:
		# Declare types for touch positions and distance variables
		var touch_1_pos: Vector2 = touch_events.get(0)  # Touch position of the first finger
		var touch_2_pos: Vector2 = event.position  # Touch position of the second finger
		var new_distance: float = touch_1_pos.distance_to(touch_2_pos)  # Calculate distance between the two touch points

		# Compare with last touch distance to determine zoom direction
		if last_touch_distance != 0.0:
			var zoom_factor: float = (new_distance - last_touch_distance) * zoom_speed  # Calculate zoom factor
			zoom_distance = clamp(zoom_distance - zoom_factor, min_zoom_distance, max_zoom_distance)

		last_touch_distance = new_distance  # Update the last touch distance

	# Handle Mouse Wheel Zoom (for Desktop)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
		zoom_distance = clamp(zoom_distance - zoom_speed, min_zoom_distance, max_zoom_distance)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		zoom_distance = clamp(zoom_distance + zoom_speed, min_zoom_distance, max_zoom_distance)

	update_camera_position()

func update_camera_position() -> void:
	# Calculate the new position using spherical coordinates
	var x: float = orbit_target.global_transform.origin.x + cos(elevation) * sin(azimuth) * zoom_distance
	var y: float = orbit_target.global_transform.origin.y - sin(elevation) * zoom_distance
	var z: float = orbit_target.global_transform.origin.z + cos(elevation) * cos(azimuth) * zoom_distance
	
	# Ensure camera doesn't go below target
	global_transform.origin = Vector3(x, max(y, orbit_target.global_transform.origin.y), z)
	
	# Look at the target object
	look_at(orbit_target.global_transform.origin)
