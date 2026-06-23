extends StaticBody2D

# 编辑器参数（高速推荐180~300）
@export var move_speed: float = 220.0
@export var left_bound_x: float = -50.0
@export var right_bound_x: float = 300.0

var move_dir: float = -1.0  # 1向右，-1向左
var origin_y: float

func _ready() -> void:
	origin_y = position.y
	# 限制初始位置在区间内
	position.x = clamp(position.x, left_bound_x, right_bound_x)
	# 自动播放鱼车动画
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	# 水平移动
	position.x += move_speed * move_dir * delta

	# 边界反弹换向
	if position.x >= right_bound_x:
		move_dir = -1.0
	elif position.x <= left_bound_x:
		move_dir = 1.0

	# 锁定Y轴，只水平移动
	position.y = origin_y

	# 跟随移动方向翻转鱼车（适配AnimatedSprite2D）
	$AnimatedSprite2D.flip_h = move_dir < 0
