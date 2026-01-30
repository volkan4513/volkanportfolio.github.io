extends Node3D

## The object to orbit around.
@export var target_object: Node3D

## The radius of the orbit.
@export var orbit_radius: float = 5.0

## The thickness of the orbit ring.
@export var orbit_thickness: float = 0.2  # Added thickness parameter

## Number of segments to create the orbit plane. Higher values result in a smoother circle.
@export var num_segments: int = 64

## Speed of the orbit in degrees per second.
@export var orbit_speed: float = 30.0

## The plane node that represents the orbit.
var orbit_plane: MeshInstance3D

## The material for the orbit plane. You can customize this in the editor.
@export var orbit_material: Material

## The current rotation angle around the target object (in radians).
@export var rotation_angle: float = 0.0

func _ready():
	# Create the orbit plane
	orbit_plane = MeshInstance3D.new()
	var plane_mesh = ArrayMesh.new()

	var vertices = PackedVector3Array()
	var indices = PackedInt32Array()

	for i in range(num_segments):
		var angle = deg_to_rad(float(i) / num_segments * 360.0)
		var next_angle = deg_to_rad(float(i + 1) / num_segments * 360.0)

		# Calculate inner and outer positions for the ring
		var outer_p1 = Vector3(cos(angle) * orbit_radius, 0, sin(angle) * orbit_radius)
		var outer_p2 = Vector3(cos(next_angle) * orbit_radius, 0, sin(next_angle) * orbit_radius)
		var inner_p1 = Vector3(cos(angle) * (orbit_radius - orbit_thickness), 0, sin(angle) * (orbit_radius - orbit_thickness))
		var inner_p2 = Vector3(cos(next_angle) * (orbit_radius - orbit_thickness), 0, sin(next_angle) * (orbit_radius - orbit_thickness))

		# Create the quad for the segment
		vertices.append(outer_p1)    # 0
		vertices.append(outer_p2)    # 1
		vertices.append(inner_p1)    # 2
		vertices.append(inner_p2)    # 3

		# Add indices for the two triangles that make up the quad.
		var base_index = i * 4
		indices.append(base_index + 0)
		indices.append(base_index + 1)
		indices.append(base_index + 2)
		indices.append(base_index + 2)
		indices.append(base_index + 1)
		indices.append(base_index + 3)

	var arrays: Array = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_INDEX] = indices

	plane_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	orbit_plane.mesh = plane_mesh
	if orbit_material:
		orbit_plane.material_override = orbit_material
	add_child(orbit_plane)

	# Ensure the orbit plane is always facing upwards
	orbit_plane.rotation.x = deg_to_rad(-90)

func _process(delta):
	if target_object:
		# Keep the orbit plane centered on the target object
		orbit_plane.global_position = target_object.global_position

		# Calculate the rotation angle based on time and speed
		rotation_angle += deg_to_rad(orbit_speed * delta)
		rotation_angle = fmod(rotation_angle, TAU) # Keep angle within 0 to 2*PI

		# Keep the orbiting object at the correct radius
		global_position = target_object.global_position + Vector3(cos(rotation_angle) * orbit_radius, 0, sin(rotation_angle) * orbit_radius)

		# Update the visual rotation of this object (optional, for visual consistency if this object has a visual representation)
		rotation.x = rotation_angle
