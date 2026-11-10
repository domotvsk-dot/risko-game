extends StaticBody3D

@onready var meow_sound: AudioStreamPlayer3D = $MeowSound

func _ready() -> void:
	add_to_group("cat")

func meow() -> void:
	meow_sound.play()
