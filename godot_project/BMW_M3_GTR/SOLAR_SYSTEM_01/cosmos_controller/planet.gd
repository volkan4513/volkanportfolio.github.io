extends MeshInstance3D

func _ready() -> void:
	pass

var rotation_speed := 1.5

func _process(delta: float) -> void:
	rotate_y(delta * rotation_speed)
