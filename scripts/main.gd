class_name Main
extends NetworkManager

const PLAYER: PackedScene = preload("uid://do6wcpaaq1au1")

@onready var address: LineEdit = $JoinUi/PanelContainer/MarginContainer/VBoxContainer/Address/Address
@onready var join_ui: CanvasLayer = $JoinUi

static func check_cmdline_arg(arg: String) -> bool:
	return not OS.get_cmdline_args().find(arg) == -1


func _ready() -> void:
	if OS.has_feature("dedicated_server") or check_cmdline_arg("--host"):
		host_server()
		join_ui.hide()


func add_player(peer_id: int) -> void:
	var player: Player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)


func remove_player(peer_id: int) -> void:
	var player: Node = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()


func _on_connected_to_server() -> void:
	pass


func _on_connection_failed() -> void:
	pass


func _on_server_disconnected() -> void:
	pass


func _on_join_pressed() -> void:
	join_server(9999, address.text, NetworkingBackend.ENet)
	join_ui.hide()
