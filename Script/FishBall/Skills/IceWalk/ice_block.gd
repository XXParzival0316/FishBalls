extends StaticBody2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	var fb = get_tree().current_scene.get_node("FishBall")
	if fb:
		set_anim_total_time(animated_sprite_2d,"default",fb.iceblock_time)

func set_anim_total_time(anim_node: AnimatedSprite2D, anim_name: String, total_seconds: float):
	var frame_data = anim_node.sprite_frames
	# 获取动画总帧数
	var frame_count = frame_data.get_frame_count(anim_name)
	var target_fps = frame_count / total_seconds
	# 修改动画底层速度
	frame_data.set_animation_speed(anim_name, target_fps)
	# 写回动画节点，修改才会保存
	anim_node.sprite_frames = frame_data
