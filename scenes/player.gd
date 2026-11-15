extends CharacterBody2D

const BREAD = preload("res://scenes/bread.tscn")

@export var tile_map_layer: TileMapLayer

const SPEED = 400.0
const JUMP_VELOCITY = -600.0
var health = 160

var shooting = false
var bodyType = "player"

signal shoot_bread
signal jump_pad_activated

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if (Input.is_action_just_pressed("ui_accept") and is_on_floor()):
	#	velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = 0 if(Global.has_ended) else Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if not shooting: $sprite.play("walk")
		$sprite.flip_h = direction < 0
		
	else:
		velocity.x = velocity.x * 0.7 if is_on_floor() else velocity.x * 0.99
		if not shooting: $sprite.play("default")

	move_and_slide()
	
	_check_bounce_tile()
	
	$Bar.value = health	


func _check_bounce_tile() -> void:
	var feet := global_position + Vector2(0, 8)
	var coords := tile_map_layer.local_to_map(tile_map_layer.to_local(feet))
	var data := tile_map_layer.get_cell_tile_data(coords)
	if data and data.get_custom_data("bouncy"):
		velocity.y = JUMP_VELOCITY*float(data.get_custom_data("bounce_mult"))
		tile_map_layer.press_tile(coords)
		return
	var head := global_position - Vector2(0, 8)
	coords = tile_map_layer.local_to_map(tile_map_layer.to_local(head))
	data = tile_map_layer.get_cell_tile_data(coords)
	if data and data.get_custom_data("bouncy"):
		velocity.y = JUMP_VELOCITY*float(data.get_custom_data("bounce_mult"))
		tile_map_layer.press_tile(coords)
		return
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and not Global.has_ended and not shooting:
		shoot()

func shoot():
	shooting = true
	var new_bread: CharacterBody2D = BREAD.instantiate()
	new_bread.tile_map_layer = tile_map_layer
	shoot_bread.emit(new_bread)
	new_bread.global_position = Vector2(global_position )+(Vector2(3,3) * (-1 if ($sprite.flip_h) else 1))
	new_bread.direction = (Vector2((1 if ($sprite.flip_h) else -1),1))
	$sprite.play("shoot")
	$sprite.animation_looped.connect(
		func():
			shooting = false
	)
