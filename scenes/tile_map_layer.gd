extends TileMapLayer

@export var pressed_atlas_coords := {
	1.5: Vector2i(7, 1),
	1.0: Vector2i(6, 1)
}
var _pressed := {}

func press_tile(coords: Vector2i, duration := 0.2) -> void:
	if _pressed.has(coords):
		return
	var source_id := get_cell_source_id(coords)
	if source_id == -1:
		return

	var original_atlas := get_cell_atlas_coords(coords)
	var original_alt := get_cell_alternative_tile(coords)

	_pressed[coords] = true
	set_cell(coords, source_id, pressed_atlas_coords[get_cell_tile_data(coords).get_custom_data("bounce_mult")], original_alt)

	await get_tree().create_timer(duration).timeout

	set_cell(coords, source_id, original_atlas, original_alt)
	_pressed.erase(coords)
