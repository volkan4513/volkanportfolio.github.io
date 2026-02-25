extends VehicleBody3D

@export var STEER_SPEED = 1.5
@export var STEER_LIMIT = 0.6
@export var engine_force_value = 40.0
@export var downforce_multiplier = 2.5 # New: Controls how much the car grips the road at speed

var steer_target = 0.0

func _physics_process(delta):
	# 1. FIXED SPEED CALCULATION
	# linear_velocity.length() is exactly meters per second. 
	# No need to multiply by FPS and delta.
	var speed = linear_velocity.length()
	
	# Accurate forward speed check (checks if the car is actually moving forward or backward)
	# Assuming standard Godot orientation where -Z is forward.
	var fwd_speed = linear_velocity.dot(-transform.basis.z) 
	
	# Update HUD (3.6 is the exact mathematical conversion from m/s to km/h)
	if has_node("Hud/speed"):
		$Hud/speed.text = str(round(speed * 3.6)) + " KMPH"

	# Apply improved traction
	apply_downforce(speed)

	# 2. NEW FEATURE: DYNAMIC STEERING
	# Reduces the maximum steering angle at high speeds to prevent spinning out.
	var dynamic_steer_limit = STEER_LIMIT
	if speed > 10.0:
		dynamic_steer_limit = clamp(STEER_LIMIT * (15.0 / speed), 0.1, STEER_LIMIT)
	
	steer_target = Input.get_action_strength("ui_left") - Input.get_action_strength("ui_right")
	steer_target *= dynamic_steer_limit
	
	# Smooth steering application
	steering = move_toward(steering, steer_target, STEER_SPEED * delta)

	# Reset engine and brake by default
	engine_force = 0.0
	brake = 0.0
	
	# 3. IMPROVED ACCELERATION & BRAKING
	if Input.is_action_pressed("ui_up"):
		if fwd_speed > -1.0: 
			# Extra torque at low speeds for quick launch
			if speed < 30.0 and speed > 0.5:
				engine_force = -clamp(engine_force_value * 10.0 / speed, 0.0, 300.0)
			else:
				engine_force = -engine_force_value
		else:
			brake = 1.0 # Brake cleanly if we are rolling backwards
			
	elif Input.is_action_pressed("ui_down"):
		if fwd_speed > 1.0:
			brake = 1.0 # Brake cleanly if we are rolling forwards
		else:
			# Reverse torque
			if speed < 20.0 and speed > 0.5:
				engine_force = clamp(engine_force_value * 3.0 / speed, 0.0, 300.0)
			else:
				engine_force = engine_force_value

	# 4. FIXED DRIFT / HANDBRAKE
	if Input.is_action_pressed("ui_select"):
		brake = 1.5 # Softer brake so the front wheels don't lock up entirely
		engine_force = 0.0 # Cut the engine so you aren't fighting the brakes
		
		# 1.8 allows the car to slide smoothly without acting like it's on pure ice.
		$wheal2.wheel_friction_slip = 1.8 
		$wheal3.wheel_friction_slip = 1.8
	else:
		# NEW FEATURE: Gradual grip recovery. 
		# This prevents "snap oversteer" (spinning out when you let go of the drift button).
		$wheal2.wheel_friction_slip = move_toward($wheal2.wheel_friction_slip, 3.0, 4.0 * delta)
		$wheal3.wheel_friction_slip = move_toward($wheal3.wheel_friction_slip, 3.0, 4.0 * delta)

func apply_downforce(speed):
	# NEW FEATURE: Localized Downforce
	# Instead of Vector3.DOWN (which always pulls to the global floor), 
	# this pulls the car down relative to its own roof. Helps grip on ramps and hills!
	var downforce = -transform.basis.y * (speed * downforce_multiplier)
	apply_central_force(downforce)
