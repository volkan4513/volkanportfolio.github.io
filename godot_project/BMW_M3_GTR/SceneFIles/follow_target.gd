extends Node3D

# Declare the target node to be transformed and rotated
@export var target_node: Node3D
@export var translation_offset: Vector3 = Vector3(0, 0, 0)  # Default translation offset
@export var rotation_angle: Vector3 = Vector3(0, 0, 0)  # Default rotation angle

func _ready():
	if target_node == null:
		print("Target node not set!")
	else:
		# Perform transformations and rotations
		apply_transformations()

# Function to apply translation and rotation
func apply_transformations():
	# Apply translation (move the object by the offset)
	if target_node is Camera3D:
		target_node.transform.origin += translation_offset
	else:
		target_node.translation += translation_offset

	# Apply rotation (rotate the object by the specified angles in degrees)
	target_node.rotation_degrees += rotation_angle
	print("Applied translation and rotation to the target node.")

# Optional: A method to dynamically set the target node from another part of your code
func set_target_node(new_target: Node3D):
	target_node = new_target
	print("New target node selected.")
