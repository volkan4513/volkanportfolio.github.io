extends Button

# Declare public variables for objects to toggle visibility
@export var objects_to_toggle: Array[MeshInstance3D] = []
@export var continuous_toggle_objects: Array[MeshInstance3D] = []

# Boolean to track visibility state
var are_visible: bool = false
var is_continuous_toggling: bool = false

# Timer for continuous toggling
var toggle_timer: Timer

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	# Connect the button's "pressed" signal to the _on_Button_pressed method
	self.pressed.connect(_on_Button_pressed)
	
	var appPlugin := Engine.get_singleton("AppPlugin")
	if appPlugin:
		print("App plugin is available")

		# Signal fired from the app logic to update the gltf model being shown
		appPlugin.connect("toggle_light", _toggle_light_function)
	else:
		print("App plugin is not available")
	
	# Initialize and start the timer for continuous toggling
	toggle_timer = Timer.new()
	add_child(toggle_timer)
	toggle_timer.wait_time = 1.0  # Adjust time as needed
	toggle_timer.timeout.connect(_on_toggle_timer_timeout)
	
	# Ensure all objects are disabled at start
	for obj in objects_to_toggle:
		if obj:
			obj.visible = false
	for obj in continuous_toggle_objects:
		if obj:
			obj.visible = false

# Button click handler
func _on_Button_pressed() -> void:
	# Toggle visibility of objects_to_toggle
	are_visible = !are_visible
	for obj in objects_to_toggle:
		if obj:
			obj.visible = are_visible
	
	if is_continuous_toggling:
		# Stop continuous toggling
		is_continuous_toggling = false
		toggle_timer.stop()
		# Set continuous_toggle_objects to their last known visibility
		for obj in continuous_toggle_objects:
			if obj:
				obj.visible = are_visible
	else:
		# Start blinking continuous_toggle_objects
		is_continuous_toggling = true
		toggle_timer.start()

# Timer callback for continuous toggling
func _on_toggle_timer_timeout() -> void:
	for obj in continuous_toggle_objects:
		if obj:
			obj.visible = !obj.visible

func _toggle_light_function() -> void:
	_on_Button_pressed()
