extends Node3D

@export var orbiting_object_instances: Array[MeshInstance3D]
@export var star: Node3D
@export var orbit_speeds: Array[float]
@export var orbit_distances: Array[float]
@export var orbit_ring_segments: int = 64
@export var orbit_ring_color: Color = Color(1, 1, 1)

var orbiting_objects: Array = []
var current_angles: Array = []

func _ready():
	if star == null or orbiting_object_instances.size() != orbit_speeds.size() \
		or orbit_speeds.size() != orbit_distances.size():
		printerr("Missing star or mismatched array sizes.")
		return

	var star_origin = star.global_transform.origin
	for i in range(orbiting_object_instances.size()):
		var obj = orbiting_object_instances[i]
		if not obj is MeshInstance3D: continue
		if obj.get_parent() != self: add_child(obj)
		var angle = randf() * TAU
		current_angles.append(angle)
		orbiting_objects.append(obj)
		var pos = Vector3(cos(angle), 0.0, sin(angle)) * orbit_distances[i] + star_origin
		obj.global_transform.origin = pos
		_create_orbit_ring(orbit_distances[i], i)

func _process(delta):
	var star_origin = star.global_transform.origin
	for i in orbiting_objects.size():
		current_angles[i] += orbit_speeds[i] * delta
		var angle = current_angles[i]
		var x = cos(angle) * orbit_distances[i]
		var z = sin(angle) * orbit_distances[i]
		orbiting_objects[i].global_transform.origin = star_origin + Vector3(x, 0.0, z)

func _create_orbit_ring(radius: float, index: int):
	var mesh := ImmediateMesh.new()
	mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for j in range(orbit_ring_segments + 1):
		var angle = j * TAU / orbit_ring_segments
		mesh.surface_add_vertex(Vector3(cos(angle), 0.0, sin(angle)) * radius)
	mesh.surface_end()

	var ring := MeshInstance3D.new()
	ring.mesh = mesh
	ring.name = "OrbitRing_%d" % index
	ring.global_transform.origin = star.global_transform.origin
	var mat := StandardMaterial3D.new()
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = orbit_ring_color
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.flags_transparent = true
	ring.material_override = mat
	add_child(ring)
