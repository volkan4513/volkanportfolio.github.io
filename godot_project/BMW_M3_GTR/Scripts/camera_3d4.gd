extends Camera3D

@export var orbit_target: Node3D = null
@export var distance: float = 4.0
@export var zoom_speed: float = 1.0
@export var rotation_speed: float = 0.005
@export var min_distance: float = 2.5
@export var max_distance: float = 6.0
@export var zoom_slider: Slider = null
@export var rotate_around_x_axis: bool = true
@export var rotate_around_y_axis: bool = true
@export var rotate_around_z_axis: bool = false

@export var click_action_button: BaseButton
@export var zoom_focus_target: Node3D = null
@export var zoom_focus_distance: float = 3.0
@export var new_orbit_target: Node3D = null  # New orbit target after focus

var azimuth: float = 0.0
var elevation: float = 0.0
var left_mouse_pressed: bool = false
var touch_events: Dictionary = {}
var last_distance: float = 0.0
var zooming: bool = false
var focus_locked: bool = false  # Prevent user input after focus

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

	if zoom_slider:
		zoom_slider.value_changed.connect(_on_slider_zoom)
		zoom_slider.min_value = 0
		zoom_slider.max_value = 100
		zoom_slider.value = map_range(distance, min_distance, max_distance, 0, 100)

	if click_action_button:
		click_action_button.pressed.connect(_on_focus_button_pressed)

func _process(delta: float) -> void:
	if orbit_target and not focus_locked:
		update_camera_position()

func _input(event: InputEvent) -> void:
	if focus_locked:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_pressed = event.pressed
		if not left_mouse_pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				distance -= zoom_speed
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				distance += zoom_speed
			distance = clamp(distance, min_distance, max_distance)
			if zoom_slider:
				zoom_slider.value = map_range(distance, min_distance, max_distance, 0, 100)
			update_camera_position()

	if event is InputEventMouseMotion and left_mouse_pressed and not zooming:
		if rotate_around_y_axis:
			azimuth -= event.relative.x * rotation_speed
		if rotate_around_x_axis:
			elevation -= event.relative.y * rotation_speed
			elevation = clamp(elevation, -PI / 2 + 0.1, 0.0)
		update_camera_position()

	if event is InputEventScreenTouch:
		if event.pressed:
			touch_events[event.index] = event.position
		else:
			touch_events.erase(event.index)
			if touch_events.size() < 2:
				last_distance = 0.0
			else:
				zooming = false

	if event is InputEventScreenDrag:
		touch_events[event.index] = event.position
		if touch_events.size() == 2:
			var points: Array[Vector2] = []
			for key in touch_events:
				points.append(touch_events[key])
			if points.size() < 2:
				return
			var current_distance: float = points[0].distance_to(points[1])
			if last_distance > 0.0:
				var delta: float = current_distance - last_distance
				adjust_zoom(delta)
			last_distance = current_distance
		else:
			zooming = false

func adjust_zoom(delta: float) -> void:
	var direction: float = -delta * zoom_speed * 0.005
	distance += direction
	distance = clamp(distance, min_distance, max_distance)
	if zoom_slider:
		zoom_slider.value = map_range(distance, min_distance, max_distance, 0, 100)
	zooming = true
	update_camera_position()

func _on_slider_zoom(value: float) -> void:
	if focus_locked:
		return
	distance = map_range(value, 0, 100, min_distance, max_distance)
	update_camera_position()

func update_camera_position() -> void:
	var x: float = orbit_target.global_transform.origin.x + distance * cos(elevation) * sin(azimuth)
	var y: float = orbit_target.global_transform.origin.y - distance * sin(elevation)
	var z: float = orbit_target.global_transform.origin.z + distance * cos(elevation) * cos(azimuth)
	global_transform.origin = Vector3(x, max(y, orbit_target.global_transform.origin.y), z)
	look_at(orbit_target.global_transform.origin)

func map_range(value: float, in_min: float, in_max: float, out_min: float, out_max: float) -> float:
	return out_min + (value - in_min) * (out_max - out_min) / (in_max - in_min)

func _on_focus_button_pressed() -> void:
	if zoom_focus_target == null:
		push_warning("No focus target assigned.")
		return

	# Focus camera on the zoom target (temporarily set orbit_target to it)
	distance = clamp(zoom_focus_distance, min_distance, max_distance)
	elevation = -PI / 2 + 0.1
	azimuth = 0.0
	rotate_around_x_axis = false

	var previous_orbit_target = orbit_target
	orbit_target = zoom_focus_target
	update_camera_position()

	# Switch orbit target for future (camera won't move to it immediately)
	if new_orbit_target != null:
		orbit_target = new_orbit_target
	else:
		push_warning("New orbit target not set. Keeping existing orbit target.")

	if zoom_slider:
		zoom_slider.value = map_range(distance, min_distance, max_distance, 0, 100)

	# Lock input after focusing
	focus_locked = true

func unlock_focus() -> void:
	focus_locked = false
	rotate_around_x_axis = true
