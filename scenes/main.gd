extends Node2D
# In seconds
var timer = 5 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%player.shoot_bread.connect(func(b): 
		add_child(b)
	)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer = timer-delta
	%TimerLabel.text=str(int(floor(timer/60)))+":"+str(int(fmod(timer,60.0)))
	if(timer<0):
		%CanvasModulate.visible=true;
		%TimerLabel.visible=false;
		%EndGameLabel.visible=true;
	pass
	
