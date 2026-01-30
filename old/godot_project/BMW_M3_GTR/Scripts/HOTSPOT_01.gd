extends Node3D

@export var target_object: Node3D # Single target object
@export var click_action_button: BaseButton # First button to trigger
@export var second_action_button: BaseButton # Second button to trigger after the first

@onready var cam: Camera3D = get_viewport().get_camera_3d()
var current_hovered: Node3D = null

func _ready():
	print("🚀 Click interaction system ready!")
	if target_object:
		print("Target object:", target_object.name)
	else:
		print("⚠️ No target object assigned.")
	if click_action_button:
		print("Button for action:", click_action_button.name)
	else:
		print("⚠️ No button assigned for first action.")
	if second_action_button:
		print("Second button for chained action:", second_action_button.name)
	else:
		print("⚠️ No second button assigned for chained action.")

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
		var hit_obj = _find_target_owner(raw_hit)

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
			var clicked_obj = _find_target_owner(raw_hit)
			if clicked_obj:
				print("🖱️ Object clicked:", clicked_obj.name)
				_execute_button_action()

func _execute_button_action():
	if click_action_button:
		click_action_button.emit_signal("pressed")
		print("➡️ Simulated click on first button:", click_action_button.name)

		if second_action_button:
			second_action_button.emit_signal("pressed")
			print("➡️ Simulated click on second button:", second_action_button.name)
	else:
		print("⚠️ No first button assigned to execute action.")

func _on_button_pressed():
	print("✅ Button press action executed!")

func _find_target_owner(node: Node) -> Node3D:
	while node:
		if node == target_object:
			return node
		node = node.get_parent()
	return null
