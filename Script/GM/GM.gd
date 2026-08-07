extends Node2D

@onready var fish_ball: Player = $FishBall
@onready var dead_menu: Control = $CanvasLayer/DeadMenu
var bgm_tag:bool = false
func _ready() -> void:
	dead_menu.visible = false
	fish_ball.dead.connect(func(): 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		dead_menu.visible = true
		fish_ball.HP = 100
		)
	await get_tree().create_timer(1.0).timeout
	%BGM.play()
	bgm_tag = true
func _physics_process(delta: float) -> void:
	if bgm_tag:
		if not %BGM.is_playing():
			%BGM.play()
	if fish_ball.is_dead:
		%BGM.stop()
