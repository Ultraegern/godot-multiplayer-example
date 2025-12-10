extends NetworkManager
class_name Main

const PLAYER: PackedScene = preload("uid://do6wcpaaq1au1")

func _ready() -> void:
	if OS.has_feature("dedicated_server") or check_cmdline_arg("--host"):
		host_server()
	else:
		join_server()

func _on_connected_to_server() -> void:
	pass

func _on_connection_failed() -> void:
	pass

func _on_server_disconnected() -> void:
	pass

func add_player(peer_id: int) -> void:
	var player: Player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)

func remove_player(peer_id: int) -> void:
	var player: Node = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()

static func check_cmdline_arg(arg: String) -> bool:
	return not OS.get_cmdline_args().find(arg) == -1
