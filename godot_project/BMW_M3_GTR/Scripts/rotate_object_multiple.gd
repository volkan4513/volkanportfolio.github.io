extends Button

# Declare a public variable for the objects to be rotated (Array of Node3D)
@export var objects_to_rotate: Array[Node3D] = []

# Declare an array to store rotation values for each object (corresponding to the objects_to_rotate array)
@export var rotation_values: Array[float] = []

# Declare an array to store the rotation axis for each object (corresponding to the objects_to_rotate array)
@export var rotation_axes: Array[String] = []  # This holds the axis for each object ("x", "y", or "z")

# Boolean to check whether the objects have been rotated
var are_rotated: bool = false

# Store target rotations for smooth interpolation
var target_rotations: Array[Vector3] = []
var is_rotating: bool = false

# Speed of rotation
@export var rotation_speed: float = 2.0  # Degrees per second

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize target rotations
	for obj in objects_to_rotate:
		target_rotations.append(obj.rotation_degrees)
	# Connect the button's "pressed" signal to the _on_Button_pressed method
	self.pressed.connect(_on_Button_pressed)
	var appPlugin := Engine.get_singleton("AppPlugin")
	if appPlugin:
		print("App plugin is available")

		# Signal fired from the app logic to update the gltf model being shown
		appPlugin.connect("toggle_door", _toggle_door_function)
	else:
		print("App plugin is not available")

# Button click handler
func _on_Button_pressed() -> void:
	if objects_to_rotate.size() > 0:
		if are_rotated:
			# Reset target rotations to zero for smooth interpolation
			for i in range(objects_to_rotate.size()):
				target_rotations[i] = Vector3.ZERO
			are_rotated = false
		else:
			# Set target rotations based on the selected axis and value
			for i in range(objects_to_rotate.size()):
				var obj: Node3D = objects_to_rotate[i]
				var rotation_val: float = rotation_values[i] if i < rotation_values.size() else 1.0
				var axis: String = rotation_axes[i] if i < rotation_axes.size() else "y"
				
				match axis:
					"x":
						target_rotations[i].x += rotation_val
					"y":
						target_rotations[i].y += rotation_val
					"z":
						target_rotations[i].z += rotation_val
			are_rotated = true
		# Start rotating objects
		is_rotating = true

# Smooth rotation in _process
func _process(delta: float) -> void:
	if is_rotating:
		var all_objects_reached_target : bool = true
		for i in range(objects_to_rotate.size()):
			var obj: Node3D = objects_to_rotate[i]
			var target: Vector3 = target_rotations[i]
			
			# Lerp rotation for smooth transition
			obj.rotation_degrees = obj.rotation_degrees.lerp(target, rotation_speed * delta)
			
			# Check if the object has reached its target rotation
			if obj.rotation_degrees.distance_to(target) > 0.01:
				all_objects_reached_target = false
		
		# Stop rotating when all objects have reached their target
		if all_objects_reached_target:
			is_rotating = false

func _toggle_door_function() -> void:
	_on_Button_pressed()
