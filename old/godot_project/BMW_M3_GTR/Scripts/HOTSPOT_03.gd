extends Node3D

@export var target_object: Node3D
@export var click_action_button: BaseButton
@export var second_action_button: BaseButton

@export var use_third_button: bool = false # ✅ Public boolean toggle
@export var third_action_button: BaseButton # ✅ Optional third button

@export var debug_target_node: Node
@export var debug_target_node_value: float
var new_rotation: Vector3 = Vector3.ZERO

@onready var cam: Camera3D = get_viewport().get_camera_3d()
var current_hovered: Node3D = null

var last_clicked_object: Node3D = null
var mouse_down: bool = false

func _ready():
	print("🚀 Click interaction system ready!")

	if target_object:
		print("🎯 Target object:", target_object.name)
	else:
		print("⚠️ No target object assigned.")

	if click_action_button:
		print("🔘 First button for action:", click_action_button.name)
	else:
		print("⚠️ No button assigned for first action.")

	if second_action_button:
		print("🔄 Second button for chained action:", second_action_button.name)
	else:
		print("⚠️ No second button assigned for chained action.")

	if use_third_button:
		if third_action_button:
			print("➕ Third button enabled:", third_action_button.name)
		else:
			print("⚠️ Third button is enabled but not assigned!")

func _process(_delta):
	_check_mouse_hover()

func _check_mouse_hover():
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

		if hit_obj and hit_obj != current_hovered:
			current_hovered = hit_obj
			print("👆 Hovering over:", current_hovered.name)
		elif not hit_obj and current_hovered:
			print("👋 No longer hovering over:", current_hovered.name)
			current_hovered = null
	else:
		if current_hovered:
			print("👋 No longer hovering over:", current_hovered.name)
			current_hovered = null

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				mouse_down = true
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

					if clicked_obj and clicked_obj != last_clicked_object:
						last_clicked_object = clicked_obj
						print("🖱️ Object clicked:", clicked_obj.name)
						_execute_button_action()
			else:
				mouse_down = false
				last_clicked_object = null

func _execute_button_action():
	if debug_target_node:
		new_rotation.y = deg_to_rad(debug_target_node_value)
		debug_target_node.rotation = new_rotation
		print("🌀 Rotated debug node:", debug_target_node.name)

	if click_action_button:
		click_action_button.emit_signal("pressed")
		print("➡️ Simulated click on first button:", click_action_button.name)

		if second_action_button:
			second_action_button.emit_signal("pressed")
			print("➡️ Simulated click on second button:", second_action_button.name)

		if use_third_button and third_action_button:
			third_action_button.emit_signal("pressed")
			print("➡️ Simulated click on third button:", third_action_button.name)
		elif use_third_button and not third_action_button:
			print("⚠️ Third button is enabled but not assigned!")
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
