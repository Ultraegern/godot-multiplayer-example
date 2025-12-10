extends Node
class_name PlayerDB 

var player_db: Dictionary[int, PlayerInfo] = {}

func _overwrite_player_db(new_player_db: Dictionary) -> void:
	player_db = new_player_db

func _update_player_db(peer_id: int, data: PlayerInfo) -> void:
	data.multiplayer_id = peer_id
	player_db[peer_id] = data

# Calls receive_player_db() on every client. Called by the server to broadcast the full DB to every peer.
func _broadcast_player_db() -> void:
	receive_player_db.rpc(player_db)
	print(player_db)

# Called by the server to send the player_db to new clients.
func _send_initial_db(peer_id: int) -> void:
	receive_player_db.rpc_id(peer_id)

# Runs on the client. Called by the server to broadcast the full DB.
@rpc("call_local", "reliable")
func receive_player_db(new_player_db: Dictionary) -> void:
	_overwrite_player_db(new_player_db)

# Calls register_player_info(). Called by new peers to add their info.
func send_initial_info(player_info: PlayerInfo) -> void:
	register_player_info.rpc_id(1, player_info.serialize_to_dictionary()) 

# Runs on the server. Called by new peers to add their info.
@rpc("any_peer", "reliable")
func register_player_info(serialized_data: Dictionary) -> void:
update_player_db(get_tree().multiplayer.get_calling_peer(), PlayerInfo.deserialize_from_dictionary(serialized_data))
	_broadcast_player_db()
