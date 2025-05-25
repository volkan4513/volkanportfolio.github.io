extends Node3D

@export var orbiting_object_instances: Array[MeshInstance3D]
@export var star: Node3D
@export var orbit_speeds: Array[float]
@export var orbit_distances: Array[float]
@export var orbit_pitches: Array[float] # Controls vertical oscillation amplitude

var orbiting_objects: Array = []
var current_angles: Array = []
var orbit_radii: Array = []
var vertical_offsets: Array = []

func _ready():
	if star == null:
		printerr("Star Node3D is null. Please assign one in the Inspector.")
		return

	create_planets()

func create_planets():
	if orbiting_object_instances.size() != orbit_speeds.size() or orbiting_object_instances.size() != orbit_distances.size() or orbiting_object_instances.size() != orbit_pitches.size():
		printerr("Error: Arrays must be the same size.")
		return

	for i in range(orbiting_object_instances.size()):
		var orbiting_object = orbiting_object_instances[i]
		if not orbiting_object is MeshInstance3D:
			printerr("Element %d of 'Orbiting Object Instances' is not a MeshInstance3D." % i)
			continue

		# Ensure it's a child of this node
		if orbiting_object.get_parent() != self:
			add_child(orbiting_object)

		orbiting_objects.append(orbiting_object)

		var radius = orbit_distances[i]
		orbit_radii.append(radius)

		var speed = orbit_speeds[i]
		current_angles.append(randf() * 2.0 * PI)

		vertical_offsets.append(0.0)

		var angle = current_angles[i]
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		var y = 0.0
		orbiting_object.global_transform.origin = star.global_transform.origin + Vector3(x, y, z)

func _process(delta):
	for i in range(orbiting_objects.size()):
		current_angles[i] += orbit_speeds[i] * delta

		# Oscillate vertically using a sine wave
		vertical_offsets[i] = sin(current_angles[i]) * orbit_pitches[i]

		var radius = orbit_radii[i]
		var angle = current_angles[i]
		var x = cos(angle) * radius
		var z = sin(angle) * radius
		var y = vertical_offsets[i]

		var new_pos = star.global_transform.origin + Vector3(x, y, z)
		orbiting_objects[i].global_transform.origin = new_pos
