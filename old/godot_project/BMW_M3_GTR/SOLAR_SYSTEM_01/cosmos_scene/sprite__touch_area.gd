extends Node3D

@export var sprite_3d: Sprite3D
@export var subviewport: SubViewport

func _ready():
	# Assign SubViewport texture to Sprite3D
	sprite_3d.texture = subviewport.get_texture()

func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		var screen_pos = event.position

		# Get the active camera
		var camera = get_viewport().get_camera_3d()
		if camera:
			var from = camera.project_ray_origin(screen_pos)
			var to = from + camera.project_ray_normal(screen_pos) * 1000

			var space_state = get_world_3d().direct_space_state

			# ✅ Use PhysicsRayQueryParameters3D
			var ray_params = PhysicsRayQueryParameters3D.create(from, to)
			ray_params.collide_with_areas = true
			ray_params.collide_with_bodies = true

			var result = space_state.intersect_ray(ray_params)

			if result and result.has("collider") and result["collider"] == sprite_3d:
				var hit_pos = result["position"]
				print("Touched Sprite3D at world position: ", hit_pos)
