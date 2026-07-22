extends StaticBody2D

# 和锅一样，先拿到Area2D
@onready var area_2d: Area2D = $Area2D
@onready var coll_shape: CollisionShape2D = $CollisionShape2D

# 编辑器可调参数
@export var delay_before_shake: float = 0.5   # 踩后多久抖
@export var shake_duration: float = 0.3       # 抖动多久
@export var shake_strength: float = 1.0       # 抖动幅度
@export var respawn_delay: float = 2.0         # 销毁后等待2秒重生

var is_triggered: bool = false
var original_pos: Vector2
var shake_timer: float = 0.0


func _ready() -> void:
	original_pos = position
	randomize()  # 随机种子，抖动自然


# 玩家进入
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_triggered:
		is_triggered = true
		# 延迟后开始抖
		get_tree().create_timer(delay_before_shake).timeout.connect(_start_shake)


# 玩家离开（可选：离开就取消计时）
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and not shake_timer > 0:
		is_triggered = false


func _start_shake():
	shake_timer = shake_duration


func _physics_process(delta: float) -> void:
	if shake_timer > 0:
		shake_timer -= delta
		# 抖动：原地随机偏移
		position.x = original_pos.x + randf_range(-shake_strength, shake_strength)
		position.y = original_pos.y + randf_range(-shake_strength, shake_strength)

		# 抖动结束：隐藏+关闭碰撞，2秒后重生
		if shake_timer <= 0:
			# 模拟销毁：隐藏+禁用实体碰撞
			visible = false
			coll_shape.disabled = true
			# 启动重生计时器
			get_tree().create_timer(respawn_delay).timeout.connect(_respawn_icefloor)


# 重生恢复函数
func _respawn_icefloor() -> void:
	# 复位到初始状态
	position = original_pos
	visible = true
	coll_shape.disabled = false
	is_triggered = false
	shake_timer = 0.0
