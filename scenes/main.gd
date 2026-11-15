extends Node2D
# In seconds
var timer = 5 * 60 

var enemies: Array[Node2D] = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	enemies = [$enemy,
$enemy2,
$enemy3,
$enemy4,
$enemy5,
$enemy6]
	%player.shoot_bread.connect(func(b): 
		add_child(b)
	)
	%player.jump_pad_activated.connect(func(coords: Vector2): 
		pass
	)
	Global.nav.build($TileMapLayer, 300, 600, -600)
	
	for enemy in enemies:
		enemy.shoot_bread.connect(func(b): 
			add_child(b)
		)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer = timer-delta
	%TimerLabel.text=str(int(floor(timer/60)))+":"+str(int(fmod(timer,60.0)))
	if(timer<0 or Global.has_ended):
		%CanvasModulate.visible=true;
		%TimerLabel.visible=false;
		if Global.win_state: %WinGameLabel.visible=true;
		else: %LoseGameLabel.visible=true;
		Global.has_ended=true;
	pass
	
	if enemies.all(func(e): return not is_instance_valid(e)):
		Global.has_ended = true
		Global.win_state = true
	
