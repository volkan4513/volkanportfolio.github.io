extends Node3D

@export var orbiting_object_instances: Array[MeshInstance3D]
@export var star: Node3D
@export var orbit_speeds: Array[float]
@export var orbit_distances: Array[float]
@export var orbit_ring_segments: int = 64
@export var orbit_ring_color: Color = Color(1, 1, 1)
@export var click_action_button: BaseButton
@export var master_ring_radius: float = 20.0

var orbiting_objects: Array = []
var current_angles: Array = []
var master_ring_enabled: bool = false

@export var test_button: BaseButton
@export var benchmark_duration: float = 10.0
@export var speed_multiplier: float = 10.0
@export var segment_increment_interval: float = 1.0
@export var max_ring_segments: int = 512

var _test_time_passed: float = 0.0
var _benchmark_active: bool = false
var _segment_update_timer: float = 0.0

@export var debug_label_ui: Label  # This will be the Label node to display debug information



func _ready():
	if star == null or orbiting_object_instances.size() != orbit_speeds.size() \
		or orbit_speeds.size() != orbit_distances.size():
		printerr("Missing star or mismatched array sizes.")
		return

	if click_action_button != null:
		click_action_button.pressed.connect(create_master_ring)

	var star_origin = star.transform.origin
	for i in range(orbiting_object_instances.size()):
		var obj = orbiting_object_instances[i]
		if not obj is MeshInstance3D:
			continue
		if obj.get_parent() != self:
			add_child(obj)

		var angle = randf() * TAU
		current_angles.append(angle)
		orbiting_objects.append(obj)

		var local_pos = Vector3(cos(angle), 0.0, sin(angle)) * orbit_distances[i] + star_origin
		obj.transform.origin = local_pos
		_create_orbit_ring(orbit_distances[i], i, star_origin)
		
		if test_button:
			test_button.pressed.connect(test_func)

func _process(delta):
	if master_ring_enabled:
		return

	var star_origin = star.transform.origin
	for i in orbiting_objects.size():
		current_angles[i] += orbit_speeds[i] * delta
		var angle = current_angles[i]
		var x = cos(angle) * orbit_distances[i]
		var z = sin(angle) * orbit_distances[i]
		orbiting_objects[i].transform.origin = star_origin + Vector3(x, 0.0, z)

	# ✅ Benchmark timing logic
	if _benchmark_active:
		_test_time_passed += delta
		_segment_update_timer += delta

		# Log time every second for debugging
		if int(_test_time_passed) != int(_test_time_passed - delta):
			if debug_label_ui:
				debug_label_ui.text = "Benchmark time passed: %f seconds" % _test_time_passed

		if _segment_update_timer >= segment_increment_interval:
			_segment_update_timer = 0.0
			orbit_ring_segments = min(orbit_ring_segments + 32, max_ring_segments)

			# Update the label with the new segment count
			if debug_label_ui:
				debug_label_ui.text = "Increased orbit_ring_segments to %d" % orbit_ring_segments

			# Redraw rings
			for child in get_children():
				if child is MeshInstance3D and child.name.begins_with("OrbitRing_"):
					child.queue_free()
			star_origin = star.transform.origin
			for i in range(orbiting_objects.size()):
				_create_orbit_ring(orbit_distances[i], i, star_origin)

		if _test_time_passed >= benchmark_duration:
			print("✅ Benchmark complete.")
			_benchmark_active = false

			# Update the label to show completion
			if debug_label_ui:
				debug_label_ui.text = "Benchmark complete. Final object count: %d" % orbiting_objects.size()

			# Re-enable the button and change its text and color back
			if test_button:
				test_button.disabled = false
				test_button.text = "start benchmark"  # Reset text
				test_button.modulate = Color(1, 1, 1)  # Reset color to default (white)





func _create_orbit_ring(radius: float, index: int, origin: Vector3):
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for j in range(orbit_ring_segments + 1):
		var angle = j * TAU / orbit_ring_segments
		var pos = Vector3(cos(angle), 0.0, sin(angle)) * radius + origin
		mesh.surface_add_vertex(pos)
	mesh.surface_end()

	var ring := MeshInstance3D.new()
	ring.mesh = mesh
	ring.name = "OrbitRing_%d" % index
	ring.transform.origin = Vector3.ZERO  # Positioned by mesh vertices

	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = orbit_ring_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_transparent = true
	ring.material_override = mat
	add_child(ring)

func create_master_ring():
	if master_ring_enabled:
		return  # Prevent re-entry if already enabled

	master_ring_enabled = true

	if star == null:
		printerr("Star not defined.")
		return

	var original_star := star
	var ring_center = original_star.transform.origin

	var new_star := Node3D.new()
	new_star.name = "MasterRingCenter"
	new_star.transform.origin = ring_center
	add_child(new_star)
	star = new_star

	var all_objects := orbiting_object_instances.duplicate()
	all_objects.append(original_star)

	var num_objects = all_objects.size()
	if num_objects == 0:
		return

	var angle_step = TAU / num_objects
	for i in range(num_objects):
		var obj = all_objects[i]
		if not obj is Node3D:
			continue
		var angle = angle_step * i
		var offset = Vector3(cos(angle), 0.0, sin(angle)) * master_ring_radius
		obj.transform.origin = ring_center + offset
		if obj.get_parent() != self:
			add_child(obj)

	for child in get_children():
		if child is MeshInstance3D and child.name.begins_with("OrbitRing_"):
			child.queue_free()

	_create_orbit_ring(master_ring_radius, -1, ring_center)

func test_func():
	if _benchmark_active:
		return
	print("starting benchmark test...")

	# Disable the button so it can't be pressed again during the benchmark
	if test_button:
		test_button.disabled = true
		test_button.text = "benchmark running"  # Change text
		test_button.modulate = Color(1, 0, 0)  # Change color to red for visual feedback

	_benchmark_active = true
	_test_time_passed = 0.0
	_segment_update_timer = 0.0

	# Increase speeds drastically
	for i in range(orbit_speeds.size()):
		orbit_speeds[i] *= speed_multiplier

	# Remove existing rings
	for child in get_children():
		if child is MeshInstance3D and child.name.begins_with("OrbitRing_"):
			child.queue_free()

	# Reset ring segments
	orbit_ring_segments = 64

	# Duplicate orbiting nodes
	var original_count = orbiting_object_instances.size()
	for i in range(original_count):
		var original_obj = orbiting_object_instances[i]
		var duplicate_obj = original_obj.duplicate()
		add_child(duplicate_obj)
		orbiting_object_instances.append(duplicate_obj)
		
		var speed = orbit_speeds[i]
		var distance = orbit_distances[i]
		var angle = randf() * TAU

		orbit_speeds.append(speed)
		orbit_distances.append(distance)
		current_angles.append(angle)
		orbiting_objects.append(duplicate_obj)

		var star_origin = star.transform.origin
		var pos = Vector3(cos(angle), 0.0, sin(angle)) * distance + star_origin
		duplicate_obj.transform.origin = pos

		_create_orbit_ring(distance, orbiting_objects.size() - 1, star_origin)

	# Update the UI label with initial debug information
	if debug_label_ui:
		debug_label_ui.text = "Benchmark started. Duplicated %d nodes." % orbiting_objects.size()
