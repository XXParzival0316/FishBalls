extends StaticBody2D

# 和锅一样，先拿到Area2D
@onready var area_2d: Area2D = $Area2D

# 编辑器可调参数
@export var delay_before_shake: float = 2.0   # 踩后多久抖
@export var shake_duration: float = 2.0       # 抖动多久
@export var shake_strength: float = 3.0       # 抖动幅度

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
		# 2秒后开始抖
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

		# 时间到，销毁
		if shake_timer <= 0:
			free()
