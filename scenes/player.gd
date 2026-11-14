extends CharacterBody2D

const BREAD = preload("res://scenes/bread.tscn")

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

signal shoot_bread

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot()

func shoot():
	var new_bread: CharacterBody2D = BREAD.instantiate()
	shoot_bread.emit(new_bread)
	new_bread.global_position = global_position + Vector2()
