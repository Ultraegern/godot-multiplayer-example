extends Node2D
class_name Main

const PLAYER: PackedScene = preload("uid://do6wcpaaq1au1")

enum NetworkingBackend {ENet, WebSocket, WebSocketSecure}

func _ready() -> void:
	if OS.has_feature("dedicated_server") or check_cmdline_arg("--host"):
		host_server()
	else:
		join_server()

func host_server(port: int = 9999, networking_backend: NetworkingBackend = NetworkingBackend.ENet) -> void:
	match networking_backend:
		NetworkingBackend.ENet:
			var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
			enet_peer.create_server(port)
			multiplayer.multiplayer_peer = enet_peer
			multiplayer.peer_connected.connect(
				func(peer_id: int) -> void:
					add_player(peer_id)
					#rpc_id(peer_id, "register_previously_added_players", player_info)
					)
			multiplayer.peer_disconnected.connect(
				func(peer_id: int) -> void:
					remove_player(peer_id)
					)
			print("Started ENet server on port " + str(port))
		
		NetworkingBackend.WebSocket:
			var websocket_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
			websocket_peer.create_server(port)
			multiplayer.multiplayer_peer = websocket_peer
			multiplayer.peer_connected.connect(
				func(peer_id: int) -> void:
					add_player(peer_id)
					#rpc_id(peer_id, "register_previously_added_players", player_info)
					)
			multiplayer.peer_disconnected.connect(
				func(peer_id: int) -> void:
					remove_player(peer_id)
					)
			print("Started WebSocket server on port " + str(port))
	pretty_print_ip_interfaces()

func add_player(peer_id: int) -> void:
	var player: Player = PLAYER.instantiate()
	player.name = str(peer_id)
	add_child(player)
	print("Player " + str(peer_id) + " joined")

func remove_player(peer_id: int) -> void:
	var player: Node = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
	print("Player " + str(peer_id) + " left")

func join_server(port: int = 9999, address: String = "127.0.0.1", networking_backend: NetworkingBackend = NetworkingBackend.ENet) -> void:
	match networking_backend:
		NetworkingBackend.ENet:
			var enet_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
			var error: Error = enet_peer.create_client(address, port)
			if not error == OK:
				push_error(error)
			multiplayer.multiplayer_peer = enet_peer
		
		NetworkingBackend.WebSocket:
			var websocket_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
			var error: Error = websocket_peer.create_client("ws://" + address + ":" + str(port))
			if not error == OK:
				push_error(error)
			multiplayer.multiplayer_peer = websocket_peer
		
		NetworkingBackend.WebSocketSecure:
			var websocket_peer: WebSocketMultiplayerPeer = WebSocketMultiplayerPeer.new()
			var error: Error = websocket_peer.create_client("wss://" + address + ":" + str(port))
			if not error == OK:
				push_error(error)
			multiplayer.multiplayer_peer = websocket_peer

static func pretty_print_ip_interfaces() -> void:
	print("")
	print("--- Local Network Interfaces ---")
	var interfaces: Array = IP.get_local_interfaces()
	if interfaces.is_empty():
		print("No local interfaces found.")
		return
	for interface in interfaces:
		var interface_name: String = interface.get("name", "N/A")
		var friendly: String = interface.get("friendly", "N/A")
		var ip_addresses: Array = interface.get("addresses", [])
		var ip_string: String = ", ".join(ip_addresses)
		
		print("Name:     %s" % interface_name)
		print("Friendly: %s" % friendly)
		print("IP(s):    %s" % ip_string)
		print("------------------------------")
	print("")

static func check_cmdline_arg(arg: String) -> bool:
	return not OS.get_cmdline_args().find(arg) == -1
