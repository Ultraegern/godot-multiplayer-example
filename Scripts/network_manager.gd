extends Node
class_name NetworkManager

signal connected_to_server
signal connection_failed
signal server_disconnected

const PLAYER: PackedScene = preload("uid://do6wcpaaq1au1")

@onready var player_db: PlayerDB = PlayerDB.new()

# Use ENet unless you are building for web
enum NetworkingBackend {ENet, WebSocket, WebSocketSecure}

func join_server(port: int = 9999, address: String = "127.0.0.1", player_info: PlayerInfo = PlayerInfo.create("123ABC"), networking_backend: NetworkingBackend = NetworkingBackend.ENet) -> void:
	var peer: MultiplayerPeer
	var error: Error
	
	match networking_backend:
		NetworkingBackend.ENet:
			peer = ENetMultiplayerPeer.new()
			error = peer.create_client(address, port)
		
		NetworkingBackend.WebSocket:
			peer = WebSocketMultiplayerPeer.new()
			error = peer.create_client("ws://" + address + ":" + str(port))
		
		NetworkingBackend.WebSocketSecure:
			peer = WebSocketMultiplayerPeer.new()
			error = peer.create_client("wss://" + address + ":" + str(port))
	
	if not error == OK: push_error(error)
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

func _on_connected_to_server() -> void:
	connected_to_server.emit()
	player_db.send_initial_info(PlayerInfo.create("123ABC"))

func _on_connection_failed() -> void:
	connection_failed.emit()

func _on_server_disconnected() -> void:
	server_disconnected.emit()

func host_server(port: int = 9999, networking_backend: NetworkingBackend = NetworkingBackend.ENet, tls_options_only_for_WebSocketSecure: TLSOptions = null) -> void:
	var peer: MultiplayerPeer
	var error: Error
	
	match networking_backend:
		NetworkingBackend.ENet:
			peer = ENetMultiplayerPeer.new()
			error = peer.create_server(port)
			print("Started ENet server on port " + str(port))
		
		NetworkingBackend.WebSocket:
			peer = WebSocketMultiplayerPeer.new()
			error = peer.create_server(port)
			print("Started WebSocket server on port " + str(port))
		
		NetworkingBackend.WebSocketSecure:
			peer = WebSocketMultiplayerPeer.new()
			if tls_options_only_for_WebSocketSecure == null:
				push_error("Cannot start WebSocketSecure (WSS) server. The 'tls_options_only_for_WebSocketSecure' parameter is NULL. Please provide a valid TLSOptions object (containing the server certificate and key files) to enable TLS encryption.")
				error = ERR_INVALID_PARAMETER 
			else:
				error = peer.create_server(port, tls_options_only_for_WebSocketSecure)
			print("Started WebSocketSecure server on port " + str(port))
	
	if not error == OK: push_error(error)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	pretty_print_ip_interfaces()

func _on_peer_connected(peer_id: int):
	add_player(peer_id)
	player_db._send_initial_db(peer_id)

func _on_peer_disconnected(peer_id: int):
	remove_player(peer_id)

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

func pretty_print_ip_interfaces() -> void:
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
