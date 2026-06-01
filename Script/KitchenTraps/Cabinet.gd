extends StaticBody2D

# 自定义交互信号
signal interact_tips(can_interact: bool, scene_name: String)

@onready var area_2d: Area2D = $Area2D
# 目标跳转场景名，编辑器内直接填写
@export var target_scene: String = "CabinetScene"
# 代码控制识别区尺寸

@export var detect_range: Vector2 = Vector2(90, 75)

var player_target = null
var can_interact = false

func _ready() -> void:
	# 代码设置识别区大小（无需手动拖拽碰撞体）
	var area_coll = area_2d.get_child(0)
	if area_coll is CollisionShape2D and area_coll.shape is RectangleShape2D:
		area_coll.shape.size = detect_range

# 玩家进入识别区：开启交互 + 发送信号
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body
		if not can_interact:
			can_interact = true
			emit_signal("interact_tips", true, target_scene)
			print("按下e可跳转至对应关卡")

# 玩家离开识别区：关闭交互 + 发送信号
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target = null
		if can_interact:
			can_interact = false
			emit_signal("interact_tips", false, target_scene)
			print("")
