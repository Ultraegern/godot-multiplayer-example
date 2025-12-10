extends Resource
class_name PlayerInfo

@export var multiplayer_id: int = 0 # Server sets id when it recives PlayerInfo
@export var nametag: String
@export var color: Color

static func get_random_color() -> Color:
	return Color.from_hsv(randf(), 0.8, 1.0)

static func create(nametag_text: String) -> PlayerInfo:
	var player_info := PlayerInfo.new()
	player_info.nametag = nametag_text
	player_info.color = get_random_color()
	return player_info

func serialize_to_dictionary() -> Dictionary:
	return {
		"nametag": nametag,
		"color": color
	}

static func deserialize_from_dictionary(dict: Dictionary) -> PlayerInfo:
	var player_info := PlayerInfo.new()
	player_info.nametag = dict.get("nametag", "")
	player_info.color = dict.get("color", Color.BLACK)
	return player_info
