extends CharacterBody2D

const INITIAL_SPEED: int = 500
var speed: int = INITIAL_SPEED
var direction: Vector2
var collision_count = 0

var squish_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	direction = Vector2(0.5, 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if collision_count >= 10: queue_free()
	direction *= Vector2(1, randf_range(0.9997, 1.0002))
	direction -= Vector2(0, -0.08)
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		collision_count += 0.5
		direction = direction.bounce(collision.get_normal().rotated(randf_range(-0.01, 0.01)))
		squish(collision.get_normal())

func squish(normal: Vector2) -> void:
	if squish_tween:
		squish_tween.kill()

	var squashed := Vector2(0.6, 1.4) if absf(normal.x) > absf(normal.y) else Vector2(1.4, 0.6)
	%Sprite2D.scale = squashed 
	squish_tween = create_tween()
	squish_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	squish_tween.tween_property(%Sprite2D, "scale", Vector2.ONE, 0.25)
