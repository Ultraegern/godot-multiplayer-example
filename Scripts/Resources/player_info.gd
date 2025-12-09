extends RefCounted
class_name PlayerInfo

@export var nametag: String
@export var color: Color

func set_random_color() -> void:
	color = Color.from_hsv(randf(), 0.8, 1.0)
