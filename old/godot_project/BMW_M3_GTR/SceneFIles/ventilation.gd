extends Node  # Keeps it lightweight

@export var airflow_vent: airflow_vent  # Drag & drop the airflow_vent node (holds_ac_flow_planes)
@export var button: Button  # Drag & drop the ventilation button

func _ready():
	# Ensure both references are assigned
	if button and airflow_vent:
		button.pressed.connect(_on_button_pressed)
		print("✅ Ventilation Controller connected to button:", button.name)
	else:
		print("❌ ERROR: Missing airflow_vent or button assignment!")

func _on_button_pressed():
	print("🟢 Button Pressed!")  # Debug

	if airflow_vent:
		# Toggle visibility
		airflow_vent.show_mesh = !airflow_vent.show_mesh  
		print("🔄 Toggled airflow visibility:", airflow_vent.show_mesh)

		# Check if meshes are updating correctly
		for mesh in airflow_vent.target_meshes:
			if mesh:
				print("Mesh:", mesh.name, "Visibility:", mesh.visible)
			else:
				print("❌ ERROR: One of the target_meshes is NULL!")
	else:
		print("❌ ERROR: airflow_vent is NULL!")
