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
