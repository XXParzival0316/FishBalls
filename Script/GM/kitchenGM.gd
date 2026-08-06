extends Node2D

@export var first_play_game:bool = false

@onready var fish_ball: Player = %FishBall
@onready var frame_animation: FrameAnimation = $FrameAnimation
@onready var camera_2d: Camera2D = %Camera2D
var target_zoom = Vector2(1.0,1.0)
var begin_zoom:bool = false
var fished_zoom:bool = false

func _ready() -> void:
	if first_play_game:
		fish_ball.input_locked = true
		camera_2d.zoom = Vector2(2.2,2.2)
		fish_ball.set_collision_layer_value(1,false)
		frame_animation.visible = true
		fish_ball.visible = false

		await get_tree().create_timer(2.0).timeout
		
		frame_animation.play_frames()
		frame_animation.play_fished.connect(func():begin_zoom = true)
		
			

func _physics_process(delta: float) -> void:
	if first_play_game:
		if begin_zoom and not fished_zoom:
			smonth_zoom()
			if camera_2d.zoom < Vector2(1.1,1.1):
				fished_zoom = true
				
	if fished_zoom:
			fish_ball.set_collision_layer_value(1,true)
			fish_ball.visible = true
			frame_animation.visible = false
			fish_ball.input_locked = false

func smonth_zoom()->void:
	camera_2d.zoom = lerp(camera_2d.zoom, target_zoom, 1 - exp(-5 * 0.01667))

	
