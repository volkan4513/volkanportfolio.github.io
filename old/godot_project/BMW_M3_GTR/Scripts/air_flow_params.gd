extends Node3D
class_name airflow_vent

@export var target_meshes: Array[MeshInstance3D]  
@export var ventilation_button: Button  # Drag and drop the button in the editor

@export var color_start: Vector4 = Vector4(1.0, 1.0, 1.0, 0.0):
	set(value):
		color_start = value
		update_shader_param("color_start", color_start)

@export var color_middle: Vector4 = Vector4(1.0, 1.0, 1.0, 0.3):
	set(value):
		color_middle = value
		update_shader_param("color_middle", color_middle)

@export var color_end: Vector4 = Vector4(1.0, 1.0, 1.0, 0.5):
	set(value):
		color_end = value
		update_shader_param("color_end", color_end)

@export var show_mesh: bool = true:
	set(value):
		show_mesh = value
		for mesh in target_meshes:
			if mesh:
				mesh.visible = show_mesh

func _ready():
	for mesh in target_meshes:
		if mesh:
			mesh.visible = show_mesh
			update_shader_param("color_start", color_start)
			update_shader_param("color_middle", color_middle)
			update_shader_param("color_end", color_end)

	# Connect to the ventilation button if assigned
	if ventilation_button:
		ventilation_button.connect("pressed", Callable(self, "_toggle_mesh_visibility"))

func update_shader_param(param_name: String, value):
	for mesh in target_meshes:
		if mesh and mesh.material_override:
			mesh.material_override.set_shader_parameter(param_name, value)

func _toggle_mesh_visibility():
	show_mesh = !show_mesh  # Toggle visibility
