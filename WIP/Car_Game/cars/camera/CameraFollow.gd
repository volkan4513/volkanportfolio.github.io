extends Camera3D

# --- NEW: Assign the car directly in the Inspector ---
@export var target_vehicle: VehicleBody3D

@export var target_distance = 5.0
@export var target_height = 2.0
@export var min_speed := 20.0
@export var max_speed := 80.0

@export var enable_dynamic_fov: bool = true
@export var base_fov = 75.0
@export var max_fov = 110.0

# We explicitly type this as a VehicleBody3D now
var follow_this: VehicleBody3D = null 
var last_lookat: Vector3

func _ready():
	# Use the assigned vehicle instead of blindly guessing the parent
	follow_this = target_vehicle
	
	if not follow_this:
		push_error("Please assign the target_vehicle in the Camera's Inspector!")
		return
		
	set_as_top_level(true) 
	last_lookat = follow_this.global_position
	fov = base_fov

func _physics_process(delta):
	if not follow_this: return
	
	var car_pos = follow_this.global_position
	var current_pos = global_position
	
	# linear_velocity now works perfectly because Godot knows follow_this is a VehicleBody3D!
	var car_speed = follow_this.linear_velocity.length()
	
	var target_fov = base_fov
	
	if enable_dynamic_fov:
		target_fov = clamp(base_fov + (car_speed * 0.8), base_fov, max_fov)
		
	fov = lerp(fov, target_fov, delta * 3.0)
	
	var delta_v = current_pos - car_pos
	delta_v.y = 0.0 
	
	if delta_v.length() > 0.1:
		delta_v = delta_v.normalized() * target_distance
		
	var target_pos = car_pos + delta_v
	target_pos.y = car_pos.y + target_height
	
	var distance_gap = current_pos.distance_to(target_pos)
	var dynamic_speed = clamp(min_speed + (distance_gap * 15.0), min_speed, max_speed)
	
	global_position = current_pos.lerp(target_pos, delta * dynamic_speed)
	
	last_lookat = last_lookat.lerp(car_pos, delta * min_speed)
	look_at(last_lookat, Vector3.UP)
