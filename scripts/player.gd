class_name Player
extends CharacterBody2D

const SPEED = 300.0


func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))
	self.modulate = get_peer_color(get_multiplayer_authority())


func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority():
		return

	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED

	move_and_slide()


# Random color based on peer_id (same peer_id always gives same color)
static func get_peer_color(peer_id: int) -> Color:
	var rng = RandomNumberGenerator.new()
	rng.seed = peer_id
	
	var h = rng.randf() 
	var s = 0.7
	var v = 0.9

	return Color.from_hsv(h, s, v)
