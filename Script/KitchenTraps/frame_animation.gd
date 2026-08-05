extends Node2D
class_name FrameAnimation

var frames:Array[Node]
signal	play_fished
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	frames = get_children()
	

func play_frames() -> void:
	for i in frames.size():
		if i != 0:
			frames[i].visible = true
			frames[i-1].visible = false
			await get_tree().create_timer(0.5).timeout
	play_fished.emit()
