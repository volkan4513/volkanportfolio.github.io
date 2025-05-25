extends Button

# Declare a public variable for the object to be rotated (Node3D)
@export var object_to_rotate: Node3D

# Declare the rotation speed as a public variable
@export var rotation_speed: float = 1.0

# Boolean to check whether the object should be reset
var is_rotated: bool = false

# Called when the button is pressed
func _ready()-> void:
	print("hello")
	# Connect the button's "pressed" signal to the _on_Button_pressed method
	var appPlugin := Engine.get_singleton("AppPlugin")
	if appPlugin:
		print("Rotate Obj App plugin is available")
		
		# Signal fired from the app logic to update the gltf model being shown
		appPlugin.connect("signal_to_rotate_object", rotate_object_from_android)
	else:
		print("Rotate Obj App plugin is not available")
		print("no dd")
	self.pressed.connect(rotate_object_from_android)

# Button click handler
func _on_Button_pressed()-> void:
	# Check if the object has been rotated or not
	if object_to_rotate:
		if is_rotated:
			# Reset the object's rotation
			object_to_rotate.rotation_degrees.y = 0
			is_rotated = false
		else:
			# Rotate the object by the specified speed
			object_to_rotate.rotation_degrees.y += 45
			is_rotated = true
			
# Expose this function for Android
func rotate_object_from_android()-> void:
	_on_Button_pressed()
	
func killMe()->void:
	get_tree().quit()
	
