extends Node3D

@export var breaths_per_minute := 24.0
@export var depth := 1.0
@export var shape_name := "breathe"

var mesh: MeshInstance3D
var idx := -1
var t := randf() * 10.0

func _ready() -> void:
	var found := find_children("*", "MeshInstance3D", true, false)
	if found.is_empty():
		push_error("No MeshInstance3D under " + name)
		return
	mesh = found[0] as MeshInstance3D
	idx = mesh.find_blend_shape_by_name(shape_name)

func _process(delta: float) -> void:
	if idx < 0:
		return
	t += delta
	var v := pow((sin(t * TAU * breaths_per_minute / 60.0) + 1.0) * 0.5, 1.5)
	mesh.set_blend_shape_value(idx, v * depth)
