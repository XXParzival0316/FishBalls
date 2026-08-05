extends Node2D

@export var first_play_game:bool = false

@onready var fish_ball: Player = %FishBall
@onready var frame_animation: FrameAnimation = $FrameAnimation
@onready var camera_2d: Camera2D = $Camera2D


func _ready() -> void:
	if first_play_game:
		frame_animation.visible = true
		fish_ball.visible = false
		fish_ball.set_collision_layer_value(1,false)
		camera_2d.reset_smoothing()
		frame_animation.play_frames()
		frame_animation.play_fished.connect(func():
			fish_ball.set_collision_layer_value(1,true)
			fish_ball.visible = true
			frame_animation.visible = false
			)
