extends Node3D
 
@export var camera_a: Camera3D
@export var camera_b: Camera3D
@export var switch_button: Button
 
var is_camera_a_active = true
 
func _ready():
	if switch_button:
		switch_button.pressed.connect(_on_switch_button_pressed)
	# Set initial camera
	if camera_a and camera_b:
		camera_a.current = true
		camera_b.current = false
		global_transform = camera_a.global_transform  # Set scene position to match Camera A
 
func _on_switch_button_pressed():
	if camera_a and camera_b:
		is_camera_a_active = !is_camera_a_active
		camera_a.current = is_camera_a_active
		camera_b.current = !is_camera_a_active
		global_transform = (camera_a if is_camera_a_active else camera_b).global_transform
