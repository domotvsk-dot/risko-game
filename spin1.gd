extends MeshInstance3D

@export var spin_speed := Vector3(0, -1.5, 0)  # radians per second (x, y, z)

func _process(delta):
	rotate_x(spin_speed.x * delta)
	rotate_y(spin_speed.y * delta)
	rotate_z(spin_speed.z * delta)
