class_name EnemyNav
extends RefCounted

enum Edge { WALK, FALL, PAD }

const MAX_DROP := 10         
const SIM_DT := 1.0 / 60.0

var layer: TileMapLayer
var astar := AStar2D.new()
var id_of: Dictionary = {}   
var cell_of: Dictionary = {}  # int -> Vector2i
var edge_info: Dictionary = {} 

var speed: float
var gravity: float
var jump_velocity: float

func _is_bouncy(c: Vector2i) -> bool:
	var d := layer.get_cell_tile_data(c)
	return d != null and d.get_custom_data("bouncy")

func _is_solid(c: Vector2i) -> bool:
	var d := layer.get_cell_tile_data(c)
	return d != null and not d.get_custom_data("bouncy") \
		and d.get_collision_polygons_count(0) > 0

func _standable(c: Vector2i) -> bool:
	if _is_solid(c):
		return false
	return _is_solid(c + Vector2i.DOWN) or _is_bouncy(c)

func build(l: TileMapLayer, spd: float, grav: float, jump_v: float) -> void:
	layer = l; speed = spd; gravity = grav; jump_velocity = jump_v
	astar.clear(); id_of.clear(); cell_of.clear(); edge_info.clear()

	# 1) nodes
	for c in layer.get_used_cells():
		for cand in [c + Vector2i.UP, c]:
			if not id_of.has(cand) and _standable(cand):
				var id := astar.get_available_point_id()
				astar.add_point(id, layer.map_to_local(cand))
				id_of[cand] = id
				cell_of[id] = cand

	# 2) edges
	for id in cell_of:
		var c: Vector2i = cell_of[id]
		for dx in [-1, 1]:
			var n := c + Vector2i(dx, 0)
			if _is_solid(n):
				continue
			if id_of.has(n):
				_link(id, id_of[n], Edge.WALK, dx, true)
			else:
				var land := _find_fall_landing(n)
				if land != Vector2i.MAX and id_of.has(land):
					_link(id, id_of[land], Edge.FALL, dx, false)
		if _is_bouncy(c):
			_add_pad_edges(id, c)

func _find_fall_landing(start: Vector2i) -> Vector2i:
	var c := start
	for i in MAX_DROP:
		if _is_solid(c):
			return Vector2i.MAX
		if _standable(c):
			return c
		c += Vector2i.DOWN
	return Vector2i.MAX

func _link(a: int, b: int, type: Edge, dir: int, two_way: bool) -> void:
	if a == b: return
	astar.connect_points(a, b, two_way)
	edge_info[Vector2i(a, b)] = {"type": type, "dir": dir}
	if two_way:
		edge_info[Vector2i(b, a)] = {"type": type, "dir": -dir}
		
func _add_pad_edges(pad_id: int, pad_cell: Vector2i) -> void:
	var mult := float(layer.get_cell_tile_data(pad_cell).get_custom_data("bounce_mult"))
	for dir in [-1, 0, 1]:
		var land := _simulate_launch(pad_cell, dir, jump_velocity * mult)
		if land != Vector2i.MAX and id_of.has(land) and land != pad_cell:
			var to_id: int = id_of[land]
			if not edge_info.has(Vector2i(pad_id, to_id)):  # keep first/cheapest
				_link(pad_id, to_id, Edge.PAD, dir, false)

func _simulate_launch(pad_cell: Vector2i, dir: int, vy: float) -> Vector2i:
	var pos := layer.map_to_local(pad_cell)
	var vel := Vector2(dir * speed, vy)
	for i in 600:
		vel.y += gravity * SIM_DT
		var next := pos + vel * SIM_DT
		var next_cell := layer.local_to_map(next)
		if _is_solid(layer.local_to_map(Vector2(next.x, pos.y))):
			vel.x = 0.0
			next.x = pos.x
		if vel.y < 0.0 and _is_solid(layer.local_to_map(Vector2(next.x, next.y - 8))):
			vel.y = 0.0
			next.y = pos.y
		if vel.y > 0.0:
			var feet_cell := layer.local_to_map(Vector2(next.x, next.y + 8))
			if _is_solid(feet_cell):
				var land := feet_cell + Vector2i.UP
				return land if _standable(land) else Vector2i.MAX
		pos = next
		if pos.y > layer.map_to_local(Vector2i(0, 10000)).y:
			break
	return Vector2i.MAX
