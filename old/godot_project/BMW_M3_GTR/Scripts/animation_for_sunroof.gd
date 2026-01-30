extends Node

# Declare an exported variable to allow dragging the AnimationPlayer node in the editor
@export var animation_player : AnimationPlayer = null

# Declare an exported variable for a single button to be assigned in the editor
@export var button : CheckButton = null

# Declare strings for the open and close animation names
@export var open_animation : String = "open"  # Default open animation name
@export var close_animation : String = "close"  # Default close animation name

# A flag to track if the animation is currently playing or not
var is_open : bool = false  # Flag to track if the open animation is playing

# Called when the node enters the scene tree for the first time.
func _ready():
	# Check if the AnimationPlayer and button are assigned
	if animation_player and button:
		#button.text = "Open"  # Set initial button text to "Open"
		# Connect the button's "pressed" signal to _on_animation_called
		button.connect("pressed", Callable(self, "_on_animation_called"))
	else:
		print("AnimationPlayer or Button is not assigned!")
	
	var appPlugin := Engine.get_singleton("AppPlugin")
	if appPlugin:
		print("App plugin is available")

		# Signal fired from the app logic to update the gltf model being shown
		appPlugin.connect("toggle_sunroof", _on_animation_called)
	else:
		print("App plugin is not available")

# Called when the button is pressed
func _on_animation_called():
	if animation_player:
		if is_open:
			# Stop the open animation and play the close animation
			animation_player.play(close_animation)
			#button.text = "Open"  # Update button text to "Open"
			print("Closing animation:", close_animation)
		else:
			# Stop the close animation and play the open animation
			animation_player.play(open_animation)
			#button.text = "Close"  # Update button text to "Close"
			print("Opening animation:", open_animation)

		# Toggle the animation state
		is_open = !is_open
	else:
		print("AnimationPlayer is not assigned!")
