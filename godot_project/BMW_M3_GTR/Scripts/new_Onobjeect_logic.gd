extends Node3D

@export var target_mesh: MeshInstance3D  # Assign your MeshInstance3D here
@export var shader_material: ShaderMaterial  # Assign your ShaderMaterial here

@export var line_color: Color = Color(1.0, 1.0, 1.0, 1.0)  # Default white color
@export var line_spacing: float = 0.3  # Default spacing between lines
@export var line_thickness: float = 0.05  # Default thickness of lines
@export var animation_speed: float = 1.0  # Speed of the line animation
@export var direction: String = "x"  # "x", "y", or "z"

var time: float = 0.0  # Tracks the elapsed time

func _ready() -> void:
	if target_mesh and shader_material:
		target_mesh.set_surface_override_material(0, shader_material)
		_update_shader_parameters()
	else:
		push_warning("Please assign both target_mesh and shader_material.")
	
	

func _process(delta: float) -> void:
	time += delta * animation_speed
	shader_material.set_shader_parameter("time", time)
	# Update the inverse rotation matrix so that the shader effect remains view-independent.
	shader_material.set_shader_parameter("inv_rot", target_mesh.global_transform.basis.inverse())

func _update_shader_parameters() -> void:
	shader_material.set_shader_parameter("line_color", line_color)
	shader_material.set_shader_parameter("line_spacing", line_spacing)
	shader_material.set_shader_parameter("line_thickness", line_thickness)

	# Validate and convert direction to integer values (x = 1, y = 2, z = 3)
	var direction_map = {"x": 0, "y": 1, "z": 2}
	if direction in direction_map:
		shader_material.set_shader_parameter("direction", direction_map[direction])
	else:
		push_warning("Invalid direction. Use 'x', 'y', or 'z'. Defaulting to 'x'.")
		shader_material.set_shader_parameter("direction", 1)

	# Set initial inv_rot uniform.
	shader_material.set_shader_parameter("inv_rot", target_mesh.global_transform.basis.inverse())
