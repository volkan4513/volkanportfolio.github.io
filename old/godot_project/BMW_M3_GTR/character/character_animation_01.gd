extends AnimationPlayer
@export var animation_name: String = "your_animation_name" # Define the animation to play via the inspector
@export var animation_speed: float = 1.0 # Control the speed of the animation (1.0 = normal speed)

func _ready():
	if animation_name != "":
		if has_animation(animation_name):
			var animation = get_animation(animation_name)
			animation.loop_mode = Animation.LOOP_LINEAR
			self.speed_scale = animation_speed # Use the built-in speed_scale property
			play(animation_name)
			print("Playing animation: %s at speed scale: %f" % [animation_name, animation_speed])
		else:
			print("Animation '%s' not found!" % animation_name)
	else:
		print("No animation name provided.")

func _process(delta):
	# Check if the animation is playing and print accordingly
	if is_playing():
		print("Animation '%s' is still playing at speed scale: %f!" % [animation_name, speed_scale])
	else:
		print("Animation is paused or stopped.")
