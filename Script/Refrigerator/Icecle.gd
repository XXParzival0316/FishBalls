extends StaticBody2D

@onready var area_2d: Area2D = $Area2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# 配置
@export var drop_small_distance: float = 10.0   # 先下落一小段
@export var shake_time: float = 1.5            # 抖动1.5秒
@export var shake_power: float = 2.0           # 抖动幅度
@export var fall_speed: float = 500.0          # 最终下落速度

# 内部状态
var original_pos: Vector2
var is_triggered: bool = false
var shake_timer: float = 0.0
var is_falling: bool = false

func _ready():
	original_pos = position
	randomize()

# 玩家进入识别区
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_triggered:
		is_triggered = true
		
		# 第一步：下落一小段
		position.y += drop_small_distance
		
		# 开始抖动
		shake_timer = shake_time

func _process(delta: float):
	# 抖动阶段
	if shake_timer > 0:
		shake_timer -= delta
		position.y = original_pos.y + drop_small_distance + randf_range(-shake_power, shake_power)
		
		# 抖动结束 → 开始下落
		if shake_timer <= 0:
			is_falling = true

	# 最终快速下落
	if is_falling:
		position.y += fall_speed * delta

func _physics_process(delta):
	pass
