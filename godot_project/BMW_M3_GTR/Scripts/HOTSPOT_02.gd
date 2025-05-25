extends Node3D

@export var target_object: Node3D # Drag in your target MeshInstance3Ds here
@onready var cam: Camera3D = get_viewport().get_camera_3d()
var current_hovered: Node3D = null

func _ready():
	print("🚀 Click interaction system ready!")

func _process(_delta):
	var mouse_pos = get_viewport().get_mouse_position()
	var from = cam.project_ray_origin(mouse_pos)
	var dir = cam.project_ray_normal(mouse_pos)
	var to = from + dir * 10000.0
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.collision_mask = 0xFFFFFFFF
	var hit = get_world_3d().direct_space_state.intersect_ray(query)

	if hit:
		var raw_hit = hit.collider
		var hit_obj = target_object

		if hit_obj:
			if hit_obj != current_hovered:
				current_hovered = hit_obj
				print("👆 Hovering over:", current_hovered.name)
		else:
			if current_hovered != null:
				print("👋 No longer hovering over:", current_hovered.name)
				current_hovered = null
	else:
		if current_hovered != null:
			print("👋 No longer hovering over:", current_hovered.name)
			current_hovered = null

func _input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_viewport().get_mouse_position()
		var from = cam.project_ray_origin(mouse_pos)
		var dir = cam.project_ray_normal(mouse_pos)
		var to = from + dir * 10000.0

		var query = PhysicsRayQueryParameters3D.create(from, to)
		query.collide_with_areas = true
		query.collide_with_bodies = true
		query.collision_mask = 0xFFFFFFFF
		var hit = get_world_3d().direct_space_state.intersect_ray(query)

		if hit:
			var raw_hit = hit.collider
			var clicked_obj = target_object
			if clicked_obj:
				print("🖱️ Object clicked:", clicked_obj.name)

func _on_button_pressed():
	# This is where you'd put the code to execute when the button is pressed
	# as a result of clicking on a target object.
	print("✅ Button press action executed!")
