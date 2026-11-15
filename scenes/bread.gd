extends CharacterBody2D

const INITIAL_SPEED: int = 500
var speed: int = INITIAL_SPEED
var direction: Vector2
var collision_count = 0
var bodyType = "bread"


var squish_tween: Tween
@export var tile_map_layer: TileMapLayer
@export var is_good: bool


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if collision_count >= 10: queue_free()
	direction *= Vector2(1, randf_range(0.9997, 1.0002))
	direction -= Vector2(0, -0.08)
	var collision = move_and_collide(direction * speed * delta)
	if collision:
		if (collision.get_collider() is CharacterBody2D):
			if(is_good and collision.get_collider().bodyType=="enemy"):
				collision.get_collider().health -= 5
				if(collision.get_collider().health<=0):collision.get_collider().queue_free();
			elif(not is_good and collision.get_collider().bodyType=="player"):
				collision.get_collider().health -= 5
				if(collision.get_collider().health<=0):	Global.has_ended=true

			
		collision_count += 0.5
		direction = direction.bounce(collision.get_normal().rotated(randf_range(-0.01, 0.01)))
		squish(collision.get_normal())
	_check_bounce_tile()

func _check_bounce_tile() -> void:
	var feet := global_position + Vector2(0, 8)
	var coords := tile_map_layer.local_to_map(tile_map_layer.to_local(feet))
	var data := tile_map_layer.get_cell_tile_data(coords)
	if data and data.get_custom_data("bouncy"):
		direction *= Vector2(1.5, 1.5)
		tile_map_layer.press_tile(coords)
func squish(normal: Vector2) -> void:
	if squish_tween:
		squish_tween.kill()

	var squashed := Vector2(0.6, 1.4) if absf(normal.x) > absf(normal.y) else Vector2(1.4, 0.6)
	%Sprite2D.scale = squashed 
	squish_tween = create_tween()
	squish_tween.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
	squish_tween.tween_property(%Sprite2D, "scale", Vector2.ONE, 0.25)
