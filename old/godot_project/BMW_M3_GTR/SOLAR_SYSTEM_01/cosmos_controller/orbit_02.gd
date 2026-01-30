extends Node3D
@export var scale_factor: float = 1.0
@export var planet : MeshInstance3D
@export var orbit : MeshInstance3D
@export var planets: Array[MeshInstance3D] = []


var orbit_mesh: MeshInstance3D
var planet_mesh : MeshInstance3D
@export var orbit_material = load("res://cosmos_mat/orbit.tres")
var rng = RandomNumberGenerator.new()
var planet_followers := []

func _ready() -> void:
	create_planet_and_orbit()


func create_planet_and_orbit() -> void:
	var total_orbit = len(planets)
	for n in range(0, total_orbit):
		
		# Create orbit mesh (optional visual ring)
		var orbit_mesh = MeshInstance3D.new()
		orbit_mesh.mesh = orbit.mesh
		if orbit_material:
			orbit_mesh.material_override = orbit_material
		orbit_mesh.scale = scale * scale_factor
		get_parent().add_child.call_deferred(orbit_mesh)

		# Create path for orbit
		var path = Path3D.new()
		var curve = Curve3D.new()
		var points := 32
		for i in range(points + 1):
			var angle = i * TAU / points
			var x = scale_factor * cos(angle)
			var z = scale_factor * sin(angle)
			curve.add_point(Vector3(x, 0, z))
		path.curve = curve
		get_parent().add_child.call_deferred(path)

		# Add PathFollow3D
		var path_follow = PathFollow3D.new()
		path_follow.loop = true
		path_follow.rotation_mode = PathFollow3D.ROTATION_NONE
		path.add_child.call_deferred(path_follow)

		var planet_mesh = planets[n]
		if planet_mesh.get_parent() != null:
			planet_mesh.get_parent().remove_child(planet_mesh)
		planet_mesh.scale = Vector3.ONE * 0.2
		path_follow.add_child.call_deferred(planet_mesh)

		path_follow.set_meta("orbit_speed", rng.randf_range(0.1, 0.5))
		planet_followers.append(path_follow)
		print("Added follower. Total:", planet_followers.size())
	
		scale_factor += rng.randf_range(0.5, 2)
