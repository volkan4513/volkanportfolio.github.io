extends Node3D

@export var rotation_speed: float = 0.005
@export var rotate_around_y_axis: bool = true
@export var zoom_speed: float = 0.05
@export var min_zoom_distance: float = 0.5
@export var max_zoom_distance: float = 10.0
@export var snap_rotation_degrees: float = 40.0
var use_snap_rotation: bool = false
var left_mouse_pressed: bool = false
var current_rotation: Vector3 = Vector3.ZERO
var current_zoom: float = 1.0
var touch_events: Dictionary = {}
@export var change_action_button: BaseButton
@export var camera_node: Camera3D
var zoom_enabled: bool = true
@export var target_object: Node3D
@export var snap_rotation_speed: float = 5.0
var is_rotating: bool = false
var target_rotation_y: float = 0.0
var use_camera_rotation: bool = false

@export_range(0.0, 1.0) var touch_area_width_percent: float = 0.5 # New variables for limiting touch input by percentage
@export_range(0.0, 1.0) var touch_area_height_percent: float = 0.5
var limit_touch_input: bool = false
var vertical_touch_input: bool = false

func _ready() -> void:
	if change_action_button:
		change_action_button.pressed.connect(_on_change_button_pressed)

func _input(event: InputEvent) -> void:
	if not zoom_enabled:
		return

	var should_handle_input := true

	if limit_touch_input:
		var pos := Vector2.ZERO
		if event is InputEventMouseButton:
			pos = event.position
		elif event is InputEventMouseMotion:
			pos = event.position
		elif event is InputEventScreenTouch or event is InputEventScreenDrag:
			pos = event.position

		var viewport_size = get_viewport().get_visible_rect().size
		var max_x = viewport_size.x * touch_area_width_percent
		var max_y = viewport_size.y * touch_area_height_percent

		if pos.x > max_x or pos.y > max_y:
			should_handle_input = false

	if not should_handle_input:
		return

	# Mouse buttons
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			left_mouse_pressed = event.pressed

		if event.button_index == MOUSE_BUTTON_WHEEL_UP or event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var zoom_delta = 0.0
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_delta = 1.0
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_delta = -1.0
			zoom(zoom_delta)

	# Mouse motion for rotation
	if event is InputEventMouseMotion and left_mouse_pressed:
		if vertical_touch_input:
			_on_touch_event_vertical(event)
		else:
			_on_touch_event_horizontal(event)

	# Touch screen drag
	if event is InputEventScreenDrag:
		if vertical_touch_input:
			_on_touch_event_vertical(event)
		else:
			_on_touch_event_horizontal(event)

	# Touch screen zoom
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_events[event.finger_index] = event.position
		else:
			if touch_events.has(event.finger_index):
				var touch_start = touch_events[event.finger_index]
				var touch_end = event.position
				var distance = touch_start.distance_to(touch_end)

				if touch_events.size() == 2:
					var previous_distance = touch_start.distance_to(touch_events[0]) if event.finger_index != 0 else touch_events[1].distance_to(touch_end)
					var zoom_delta = (distance - previous_distance) * zoom_speed
					zoom(zoom_delta)

			touch_events.erase(event.finger_index)

	if event is InputEventKey and event.pressed and not event.echo: # Snap rotation with keys
		match event.keycode:
			KEY_Q:
				snap_rotate(-snap_rotation_degrees)
			KEY_E:
				snap_rotate(snap_rotation_degrees)

func zoom(delta: float) -> void:
	if not camera_node:
		return

	var forward_dir = -camera_node.transform.basis.z.normalized()
	var new_position = camera_node.position + forward_dir * delta * zoom_speed
	var distance = new_position.distance_to(global_position)
	if distance >= min_zoom_distance and distance <= max_zoom_distance:
		camera_node.position = new_position

func snap_rotate(degrees: float) -> void:
	if is_rotating:
		return

	target_rotation_y = current_rotation.y + deg_to_rad(degrees)
	is_rotating = true

func _process(delta: float) -> void:
	if is_rotating:
		var difference = target_rotation_y - current_rotation.y
		var step = deg_to_rad(snap_rotation_speed) * delta

		if abs(difference) <= step:
			current_rotation.y = target_rotation_y
			is_rotating = false
		else:
			current_rotation.y += step * sign(difference)

		rotation = current_rotation

	if use_camera_rotation:
		camera_node.rotation_degrees.x = lerp(float(camera_node.rotation_degrees.x), -90.0, delta * 3.0)
		var target_pos = Vector3(-12.0, 4.0, 0.0)
		camera_node.position = camera_node.position.lerp(target_pos, delta * 3.0)

		if camera_node.position.distance_to(target_pos) < 0.01 and abs(camera_node.rotation_degrees.x + 90.0) < 0.5:
			use_camera_rotation = false

func _on_touch_event_horizontal(event: InputEvent) -> void:
		var rel = event.relative
		if rotate_around_y_axis and abs(rel.x) > abs(rel.y):
			if use_snap_rotation:
				if rel.x > 0:
					snap_rotate(snap_rotation_degrees)
				elif rel.x < 0:
					snap_rotate(-snap_rotation_degrees)
			else:
				current_rotation.y += rel.x * rotation_speed
				rotation = current_rotation

func _on_touch_event_vertical(event: InputEvent) -> void:
		var rel = event.relative
		if rotate_around_y_axis and abs(rel.y) > abs(rel.x):
			if use_snap_rotation:
				if rel.y > 0:
					snap_rotate(-snap_rotation_degrees)
				elif rel.y < 0:
					snap_rotate(snap_rotation_degrees)
			else:
				current_rotation.y += rel.y * rotation_speed
				rotation = current_rotation

func _on_change_button_pressed() -> void:
	position = target_object.position
	use_snap_rotation = true

	if camera_node:
		use_camera_rotation = true

	limit_touch_input = true #Enable limited input area
	vertical_touch_input = true
	
