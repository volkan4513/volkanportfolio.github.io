extends Button

@export var object_to_duplicate : Node3D
@export var offset : Vector3 = Vector3(2, 0, 0)

# To keep track of the last duplicate
var last_duplicate : Node3D = null

func _ready() -> void:
	# Connect the "pressed" signal to the duplication function
	self.connect("pressed", Callable(self, "_on_button_pressed"))

# Function to duplicate the object when the button is pressed
func _on_button_pressed() -> void:
	if object_to_duplicate:
		# Create a duplicate of the object
		var duplicate : Node3D = object_to_duplicate.duplicate()  # Use duplicate() instead of instance()
		
		# Position the duplicate based on the previous duplicate's position or the original object
		if last_duplicate:
			duplicate.global_transform.origin = last_duplicate.global_transform.origin + offset
		else:
			duplicate.global_transform.origin = object_to_duplicate.global_transform.origin + offset
		
		# Add the duplicate to the scene
		get_parent().add_child(duplicate)
		
		# Update the reference to the last duplicate
		last_duplicate = duplicate
