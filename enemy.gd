extends CharacterBody2D

@export var tile_map_layer: TileMapLayer

const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const GRAVITY = 600.0
var nav: EnemyNav
var path: PackedInt64Array = []   # astar node ids
var path_i := 0
var repath_timer := 0.0

@export var player: CharacterBody2D

func setup(n: EnemyNav, layer: TileMapLayer, p: CharacterBody2D) -> void:
	nav = n
	tile_map_layer = layer   # used by your existing _check_bounce_tile()
	player = p

func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	repath_timer -= delta
	if repath_timer <= 0.0 and is_on_floor():
		repath_timer = 0.3
		_repath()
	_follow_path()
	move_and_slide()
	_check_bounce_tile()   # your existing function

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
	if path_i >= path.size():
		velocity.x = move_toward(velocity.x, 0, SPEED)
		return
	var target_pos := Global.nav.astar.get_point_position(path[path_i])
	var dx := target_pos.x - global_position.x

	if absf(dx) < 4.0 and is_on_floor():
		path_i += 1            # reached this node, go to the next
		return

	# Pad edge: walk onto the pad; bounce triggers in _check_bounce_tile().
	# In the air, keep steering toward the landing node.
	var dir := signf(dx)
	velocity.x = dir * SPEED
	
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
		
