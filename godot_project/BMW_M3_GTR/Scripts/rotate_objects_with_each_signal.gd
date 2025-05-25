extends Button

# Declare a public variable for the objects to be rotated (Array of Node3D)
@export var objects_to_rotate: Array[Node3D] = []

# Declare an array to store rotation values for each object (corresponding to the objects_to_rotate array)
@export var rotation_values: Array[float] = []

# Declare an array to store the rotation axis for each object (corresponding to the objects_to_rotate array)
@export var rotation_axes: Array[String] = []  # This holds the axis for each object ("x", "y", or "z")

# Declare an array to store custom strings for each object
@export var custom_strings: Array[String] = []  # This holds custom strings for each object

# Boolean array to track whether each object has been rotated
var are_rotated: Array[bool] = []

# Store target rotations for smooth interpolation
var target_rotations: Array[Vector3] = []
var is_rotating: bool = false

# Speed of rotation
@export var rotation_speed: float = 2.0  # Degrees per second

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Initialize target rotations and are_rotated array
	for obj in objects_to_rotate:
		target_rotations.append(obj.rotation_degrees)
		are_rotated.append(false)  # Initialize each object as not rotated

	self.pressed.connect(_on_Button_pressed)

	var appPlugin := Engine.get_singleton("AppPlugin")
	if appPlugin:
		print("App plugin is available")

		# Create and connect individual signals for each object
		for i in range(objects_to_rotate.size()):
			var custom_str = custom_strings[i] if i < custom_strings.size() else str(i)
			var signal_name = "toggle_door_" + custom_str
			if not appPlugin.has_signal(signal_name):
				appPlugin.add_user_signal(signal_name)

			appPlugin.connect(signal_name, _toggle_door_function.bind(i))  # Bind object index

	else:
		print("App plugin is not available")

# Button click handler (toggles all objects)
func _on_Button_pressed() -> void:
	if objects_to_rotate.size() > 0:
		for i in range(objects_to_rotate.size()):
			_toggle_door_function(i)  # Toggle each object
		is_rotating = true

# Smooth rotation in _process
func _process(delta: float) -> void:
	if is_rotating:
		var all_objects_reached_target: bool = true
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

# Toggle function for each individual object
func _toggle_door_function(index: int) -> void:
	if index >= 0 and index < objects_to_rotate.size():
		var obj: Node3D = objects_to_rotate[index]

		# Toggle the rotation for each object individually
		if are_rotated[index]:
			target_rotations[index] = Vector3.ZERO
		else:
			var rotation_val: float = rotation_values[index] if index < rotation_values.size() else 1.0
			var axis: String = rotation_axes[index] if index < rotation_axes.size() else "y"
			
			match axis:
				"x":
					target_rotations[index].x += rotation_val
				"y":
					target_rotations[index].y += rotation_val
				"z":
					target_rotations[index].z += rotation_val

		# Update the rotation state for this specific object
		are_rotated[index] = !are_rotated[index]
		is_rotating = true
