extends Node2D

@onready var fish_ball: Player = $FishBall
@onready var dead_menu: Control = $CanvasLayer/DeadMenu

func _ready() -> void:
	%BGM.play()
	dead_menu.visible = false
	fish_ball.dead.connect(func(): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dead_menu.visible = true
		fish_ball.HP = 100
		)

func _physics_process(delta: float) -> void:
	if not %BGM.is_playing():
		%BGM.play()
	if fish_ball.is_dead:
		%BGM.play()
