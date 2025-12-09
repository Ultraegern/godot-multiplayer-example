extends Node2D
class_name Main


@onready var player_db: PlayerDB = $PlayerDB


func _ready() -> void:
	if OS.has_feature("dedicated_server") or check_cmdline_arg("--host"):
		host_server()
	else:
		join_server()



static func check_cmdline_arg(arg: String) -> bool:
	return not OS.get_cmdline_args().find(arg) == -1
