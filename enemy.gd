extends CharacterBody2D

@export var tile_map_layer: TileMapLayer

const BREAD = preload("res://scenes/evil_bread.tscn")

const SPEED = 300.0
const GROUND_ACCEL = 2000.0
const AIR_ACCEL = 1000.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 600.0
var path: PackedInt64Array = []   # astar node ids
var path_i := 0
var repath_timer := 0.0
var shooting =  false
var health = 100;

@export var player: CharacterBody2D

signal shoot_bread


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	repath_timer -= delta
	if repath_timer <= 0.0 and is_on_floor():
		repath_timer = 0.3
		_repath()
	_follow_path()
	move_and_slide()
	_check_bounce_tile()   # your existing function
	$Bar.value = health	

func _cell_here() -> Vector2i:
	return Global.nav.layer.local_to_map(Global.nav.layer.to_local(global_position + Vector2(0, 8)))

func _repath() -> void:
	var from_cell := _cell_here()
	var to_cell := Global.nav.layer.local_to_map(Global.nav.layer.to_local(player.global_position + Vector2(0, 8)))
	# snap to nearest known nodes if not exactly on one
	var a := Global.nav.astar.get_closest_point(Global.nav.layer.map_to_local(from_cell))
	var b := Global.nav.astar.get_closest_point(Global.nav.layer.map_to_local(to_cell))
	path = Global.nav.astar.get_id_path(a, b)
	path_i = 1 if path.size() > 1 else 0
func _follow_path() -> void:
	var delta := get_physics_process_delta_time()
	var on_floor := is_on_floor()
	var accel := GROUND_ACCEL if on_floor else AIR_ACCEL

	if path_i >= path.size():
		velocity.x = move_toward(velocity.x, 0.0, accel * delta)
		return

	var target_pos := Global.nav.astar.get_point_position(path[path_i])
	var dx := target_pos.x - global_position.x

	if on_floor and absf(dx) < 4.0:
		path_i += 1
		return

	# Fastest speed from which we can still stop at the target.
	# 0.7 is a safety factor so we never need more braking than we have.
	var max_speed := sqrt(2.0 * accel * 0.7 * absf(dx))
	var desired := signf(dx) * minf(SPEED, max_speed)

	# Close enough in the air: hold still instead of hunting
	if not on_floor and absf(dx) < 3.0:
		desired = 0.0

	velocity.x = move_toward(velocity.x, desired, accel * delta)
	
func _check_bounce_tile() -> void:
	var feet := global_position + Vector2(0, 8)
	var coords := tile_map_layer.local_to_map(tile_map_layer.to_local(feet))
	var data := tile_map_layer.get_cell_tile_data(coords)
	if data and data.get_custom_data("bouncy"):
		velocity.y = JUMP_VELOCITY*float(data.get_custom_data("bounce_mult"))
		tile_map_layer.press_tile(coords)
		_on_bounced(coords)          # <-- added
		return
	var head := global_position - Vector2(0, 8)
	coords = tile_map_layer.local_to_map(tile_map_layer.to_local(head))
	data = tile_map_layer.get_cell_tile_data(coords)
	if data and data.get_custom_data("bouncy"):
		velocity.y = JUMP_VELOCITY*float(data.get_custom_data("bounce_mult"))
		tile_map_layer.press_tile(coords)
		_on_bounced(coords)          # <-- added
		return
	
func _on_bounced(coords: Vector2i) -> void:
	if not Global.nav.id_of.has(coords):
		return
	var pad_id: int = Global.nav.id_of[coords]
	var k := path.find(pad_id)
	if k != -1 and k + 1 < path.size():
		path_i = k + 1    # skip the pad node, target the landing node
		
func shoot():
	shooting = true
	var new_bread: CharacterBody2D = BREAD.instantiate()
	new_bread.tile_map_layer = tile_map_layer
	shoot_bread.emit(new_bread)
	new_bread.global_position = global_position + Vector2()
	$sprite.play("shoot")
	$sprite.animation_looped.connect(
		func():
			shooting = false
	)
	
func _ready() -> void:
	$Timer.timeout.connect(shoot)
