extends Node2D

@onready var fish_ball: Player = $FishBall
@onready var dead_menu: Control = $CanvasLayer/DeadMenu

func _ready() -> void:
	dead_menu.visible = false
	fish_ball.dead.connect(func():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dead_menu.visible = fish_ball.is_dead
		fish_ball.HP = 100
		)
