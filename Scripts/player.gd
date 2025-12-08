extends CharacterBody2D
class_name Player

const SPEED = 300.0

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _physics_process(_delta: float) -> void:
	if not is_multiplayer_authority(): return
	
	var direction: Vector2 = Input.get_vector("left", "right", "up", "down")
	velocity = direction * SPEED
	
	move_and_slide()
