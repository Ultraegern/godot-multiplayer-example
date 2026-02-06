class_name Main
extends NetworkManager

const PLAYER: PackedScene = preload("uid://do6wcpaaq1au1")
const PORT: int = 9999
const NETWORKING_BACKEND: NetworkingBackend = NetworkingBackend.ENet

@onready var address: LineEdit = $Ui/JoinUi/PanelContainer/MarginContainer/VBoxContainer/Address/Address
@onready var join_ui: CanvasLayer = $Ui/JoinUi
@onready var host_disconnected_ui: CanvasLayer = $Ui/HostDisconnectedUi
@onready var connection_failed_ui: CanvasLayer = $Ui/ConnectionFailedUi

static func check_cmdline_arg(arg: String) -> bool:
	return not OS.get_cmdline_args().find(arg) == -1


func _ready() -> void:
	if OS.has_feature("dedicated_server") or check_cmdline_arg("--host"):
		host_server(PORT, NETWORKING_BACKEND)
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
	join_ui.hide()


func _on_connection_failed() -> void:
	join_ui.hide()
	connection_failed_ui.show()


func _on_server_disconnected() -> void:
	host_disconnected_ui.show()


func _on_join_pressed() -> void:
	join_server(PORT, address.text, NETWORKING_BACKEND)


func _on_host_disconnected_exit_pressed() -> void:
	get_tree().quit()


func _on_connection_failed_ok_pressed() -> void:
	connection_failed_ui.hide()
	join_ui.show()
