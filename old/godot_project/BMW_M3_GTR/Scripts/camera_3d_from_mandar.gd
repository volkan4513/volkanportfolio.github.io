extends Camera3D

# --- Exported Variables ---
@export var orbit_target: Node3D = null
@export var distance: float = 4.0
@export var zoom_speed: float = 1.0
@export var rotation_speed: float = 0.005
@export var min_distance: float = 2.5
@export var max_distance: float = 6.0

# --- Internal State ---
var azimuth: float = 0.0
var elevation: float = 0.0
var left_mouse_pressed: bool = false
var touch_events: Dictionary = {}
var last_distance: float = 0.0

func _ready() -> void:
	current = true
	if orbit_target == null:
		push_error("No orbit target assigned! Please assign a Node3D object to orbit around.")
		return

	var offset: Vector3 = global_transform.origin - orbit_target.global_transform.origin
	distance = offset.length()
	
	azimuth = atan2(offset.x, offset.z)
	elevation = atan2(-offset.y, sqrt(offset.x * offset.x + offset.z * offset.z))

	update_camera_position()

func _process(delta: float) -> void:
	if orbit_target:
		update_camera_position()

func _input(event: InputEvent) -> void:
	# Mouse handling
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_pressed = event.pressed

		if not left_mouse_pressed:  
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				distance -= zoom_speed
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				distance += zoom_speed
			distance = clamp(distance, min_distance, max_distance)
			update_camera_position()

	if event is InputEventMouseMotion and left_mouse_pressed:
		var prev_elevation: float = elevation
		azimuth -= event.relative.x * rotation_speed
		elevation -= event.relative.y * rotation_speed
		elevation = clamp(elevation, -PI / 2 + 0.1, 0.0)
		if elevation == -PI / 2 + 0.1 or elevation == 0.0:
			elevation = prev_elevation
		update_camera_position()

	# Touch handling
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_events[event.index] = event.position
		else:
			touch_events.erase(event.index)
			if touch_events.size() < 2:
				last_distance = 0.0

	if event is InputEventScreenDrag:
		touch_events[event.index] = event.position
		
		if touch_events.size() == 2:
			var points: Array[Vector2] = touch_events.values()
			if points.size() < 2:
				return

			var current_distance: float = points[0].distance_to(points[1])
			if last_distance > 0.0:
				var delta: float = current_distance - last_distance
				adjust_zoom(delta)
			last_distance = current_distance

func adjust_zoom(delta: float) -> void:
	# Fixed direction by removing the negative sign
	var direction: float = delta * zoom_speed * 0.005
	distance += direction
	distance = clamp(distance, min_distance, max_distance)
	update_camera_position()

func update_camera_position() -> void:
	var x: float = orbit_target.global_transform.origin.x + distance * cos(elevation) * sin(azimuth)
	var y: float = orbit_target.global_transform.origin.y - distance * sin(elevation)
	var z: float = orbit_target.global_transform.origin.z + distance * cos(elevation) * cos(azimuth)
	global_transform.origin = Vector3(x, max(y, orbit_target.global_transform.origin.y), z)
	look_at(orbit_target.global_transform.origin)
