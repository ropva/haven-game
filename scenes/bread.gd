extends CharacterBody2D

const INITIAL_SPEED: int = 650
var speed: int = INITIAL_SPEED
var direction: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = Vector2(0.5, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		direction = direction.bounce(collision.get_normal().rotated(randf_range(-0.01, 0.01)))
