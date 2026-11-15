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
var bodyType = "enemy"

@export var player: CharacterBody2D

signal shoot_bread


func _physics_process(delta: float) -> void:
	velocity.y += GRAVITY * delta
	$Bar.value = health	

	
func shoot():
	doShoot()
	await get_tree().create_timer(0.3).timeout
	doShoot()
	
func doShoot():
	shooting = true
	var new_bread: CharacterBody2D = BREAD.instantiate()
	new_bread.tile_map_layer = tile_map_layer
	new_bread.global_position = Vector2(global_position ) + 20*(player.position-global_position).normalized() + Vector2(1,0)
	new_bread.direction = (player.position-global_position).normalized()\
	*  Vector2(randf_range(0.8, 1.2), randf_range(0.7, 1.2))
	new_bread.speed = 750

	shoot_bread.emit(new_bread)
	new_bread.global_position = global_position + Vector2()	

func _ready() -> void:
	$Timer.timeout.connect(shoot)

func enemyTag():
	#lazy identification meta
	pass
