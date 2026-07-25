extends StaticBody2D

# ========== 公开面板可调参数 ==========
@export var fall_distance: float = 80.0        # 第一段下落距离
@export var shake_pre_delay: float = 0.1       # 下落完→抖动的间隔前摇
@export var shake_duration: float = 0.3        # 左右抖动总时长
@export var shake_range: float = 7.0           # 左右抖动幅度
@export var shake_frequency: float = 8.0        # 抖动频率：每秒摆动来回次数
@export var first_fall_speed: float = 300.0    # 第一段慢速下落速度
@export var real_fall_speed: float = 500.0     # 抖动结束高速下坠速度
@export var ice_damage: float = 25.0           # 击中玩家伤害值

# 状态枚举
enum ConeState {
	IDLE,        # 待机
	PRE_FALL,    # 第一段下落
	WAIT_SHAKE,  # 等待抖动前摇
	SHAKE,       # 左右抖动
	REAL_FALL,   # 高速坠落
	DESTROYED    # 销毁
}

var current_state: ConeState = ConeState.IDLE
var original_global_pos: Vector2
var is_triggered: bool = false
var shake_tween: Tween

# 识别区域（仅用来触发冰锥启动，不再管伤害）
@onready var main_area: Area2D = $Area2D
@onready var hit_area: Area2D = $HitArea

func _ready() -> void:
	original_global_pos = global_position
	main_area.body_entered.connect(_trigger_icecone_start)
	hit_area.body_entered.connect(_on_cone_body_collide)




func _process(delta: float) -> void:
	match current_state:
		ConeState.PRE_FALL:
			global_position.y += first_fall_speed * delta
		ConeState.REAL_FALL:
			global_position.y += real_fall_speed * delta

# 玩家进入识别区 → 只启动冰锥整套下落流程，无任何伤害
func _trigger_icecone_start(body: Node2D) -> void:
	if body.is_in_group("Player") and not is_triggered and current_state == ConeState.IDLE:
		is_triggered = true
		current_state = ConeState.PRE_FALL
		var fall_time = fall_distance / first_fall_speed
		await get_tree().create_timer(fall_time).timeout

		current_state = ConeState.WAIT_SHAKE
		await get_tree().create_timer(shake_pre_delay).timeout

		start_shake()
		await get_tree().create_timer(shake_duration).timeout
		stop_shake()

		current_state = ConeState.REAL_FALL

# 冰锥实体碰撞统一处理：区分撞到玩家 / 撞到地面
func _on_cone_body_collide(hit_body: Node2D) -> void:
	if current_state != ConeState.REAL_FALL:
		return
	
	# 碰撞到玩家：造成伤害+销毁冰锥
	if hit_body.is_in_group("Player"):
		hit_body.take_damage(ice_damage)
		destroy_icecone()
	# 碰撞到其他实体(地面、墙体)：直接销毁，不掉血
	else:
		destroy_icecone()

# 开启左右往复抖动
func start_shake() -> void:
	current_state = ConeState.SHAKE
	shake_tween = create_tween()
	shake_tween.set_loops() # 无限循环
	shake_tween.set_ease(Tween.EASE_IN_OUT)
	
	var one_cycle_time = 1.0 / shake_frequency
	var half_time = one_cycle_time / 2
	
	shake_tween.tween_property(self, "global_position:x", original_global_pos.x + shake_range, half_time)
	shake_tween.tween_property(self, "global_position:x", original_global_pos.x - shake_range, half_time)

# 关闭抖动、回归原始X坐标
func stop_shake() -> void:
	if shake_tween != null:
		shake_tween.kill()
	global_position.x = original_global_pos.x

# 销毁冰锥
func destroy_icecone() -> void:
	current_state = ConeState.DESTROYED
	if shake_tween:
		shake_tween.kill()
	queue_free()
