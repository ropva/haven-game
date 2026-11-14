extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%player.shoot_bread.connect(func(b): 
		add_child(b)
	)
	%player.jump_pad_activated.connect(func(coords: Vector2): 
		pass
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
