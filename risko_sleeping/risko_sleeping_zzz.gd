extends Node3D

@export var interval := 1.5
@export var height := 0.3
@export var drift := 0.2
@export var lifetime := 2
@export var letter_size := 0.0015
@export var color := Color.WHITE

var _timer := 0.0

func _process(delta: float) -> void:
	_timer += delta
	if _timer >= interval:
		_timer = 0.0
		_spawn_z()

func _spawn_z() -> void:
	var z := Label3D.new()
	z.text = "Z" if randf() > 0.3 else "z"
	z.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	z.font_size = 64
	z.pixel_size = letter_size
	z.outline_size = 10
	z.modulate = color
	z.modulate.a = 0.0
	z.scale = Vector3.ONE * 0.5
	add_child(z)

	var target := Vector3(randf_range(-drift, drift), height, 0.0)
	var tw := z.create_tween().set_parallel(true)
	tw.tween_property(z, "position", target, lifetime).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(z, "scale", Vector3.ONE * 1.2, lifetime)
	tw.tween_property(z, "modulate:a", 1.0, lifetime * 0.25)
	tw.tween_property(z, "modulate:a", 0.0, lifetime * 0.5).set_delay(lifetime * 0.5)
	tw.chain().tween_callback(z.queue_free)
