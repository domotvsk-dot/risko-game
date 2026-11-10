extends Node3D

@export var spin_speed := Vector3(0, 2.5, 0)

func _process(delta: float) -> void:
	rotate_x(spin_speed.x * delta)
	rotate_y(spin_speed.y * delta)
	rotate_z(spin_speed.z * delta)
