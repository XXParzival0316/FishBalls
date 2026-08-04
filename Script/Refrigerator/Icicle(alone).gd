extends StaticBody2D

# ========== 公开面板可调参数 ==========
@export var shake_pre_delay: float = 0.2       # 玩家进入后延迟开始晃动（秒）
@export var shake_duration: float = 0.5        # 左右晃动持续时间（秒）
@export var shake_range: float = 1.0          # 左右晃动幅度（像素）
@export var shake_frequency: float = 10.0      # 晃动频率（次/秒）
@export var fall_speed: float = 80.0          # 下落速度（像素/秒）
@export var fall_distance: float = 45.0       # 下落距离（像素）
@export var ice_damage: float = 10.0           # 击中玩家伤害值

# 状态枚举
enum ConeState {
	IDLE,        # 待机
	SHAKE,       # 左右晃动
	FALLING,     # 下落中
	DESTROYED    # 已销毁
}

var current_state: ConeState = ConeState.IDLE
var original_position: Vector2                  # 原始位置
var current_fall_distance: float = 0.0          # 已下落距离
var shake_tween: Tween                          # 晃动动画
var has_hit_player: bool = false                # 是否已击中玩家
var is_triggered: bool = false                  # 是否已触发

# 节点引用
@onready var detect_area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	# 保存原始位置
	original_position = global_position
	
	# 绑定识别区信号
	if detect_area:
		detect_area.body_entered.connect(_on_detect_area_body_entered)
		detect_area.body_exited.connect(_on_detect_area_body_exited)
	
	# 绑定碰撞体信号（用于伤害检测）
	if collision_shape:
		# 注意：StaticBody2D 的 CollisionShape2D 没有 body_entered 信号
		# 需要使用 Area2D 作为伤害检测，或者检测父节点的碰撞
		pass

# ========== 识别区信号 ==========
func _on_detect_area_body_entered(body: Node2D) -> void:
	if is_triggered or current_state != ConeState.IDLE:
		return
	
	if body.is_in_group("Player"):
		is_triggered = true
		_start_attack()

func _on_detect_area_body_exited(body: Node2D) -> void:
	# 玩家离开识别区不做特殊处理，因为已经触发
	pass

# ========== 攻击流程 ==========
func _start_attack() -> void:
	if current_state != ConeState.IDLE:
		return
	
	# 延迟后开始晃动
	await get_tree().create_timer(shake_pre_delay).timeout
	
	if current_state == ConeState.DESTROYED or not is_inside_tree():
		return
	
	# 执行晃动
	_start_shake()
	
	# 晃动持续指定时间后停止
	await get_tree().create_timer(shake_duration).timeout
	
	if current_state == ConeState.DESTROYED or not is_inside_tree():
		return
	
	# 停止晃动，开始下落
	_stop_shake()
	_start_fall()

# ========== 晃动功能 ==========
func _start_shake() -> void:
	current_state = ConeState.SHAKE
	
	shake_tween = create_tween()
	shake_tween.set_loops()
	shake_tween.set_ease(Tween.EASE_IN_OUT)
	
	var half_cycle_time = 1.0 / (shake_frequency * 2)
	
	shake_tween.tween_property(self, "global_position:x", original_position.x + shake_range, half_cycle_time)
	shake_tween.tween_property(self, "global_position:x", original_position.x - shake_range, half_cycle_time)

func _stop_shake() -> void:
	if shake_tween != null:
		shake_tween.kill()
		shake_tween = null
	global_position.x = original_position.x

# ========== 下落功能 ==========
func _start_fall() -> void:
	current_state = ConeState.FALLING
	current_fall_distance = 0.0
	has_hit_player = false
	
	# 启用碰撞检测（如果是 Area2D 伤害区域）
	# 这里使用物理碰撞检测，在 _physics_process 中处理

func _physics_process(delta: float) -> void:
	if current_state == ConeState.FALLING:
		_handle_falling(delta)

func _handle_falling(delta: float) -> void:
	var move_distance = fall_speed * delta
	var new_distance = current_fall_distance + move_distance
	
	# 检查是否到达目标距离
	if new_distance >= fall_distance:
		new_distance = fall_distance
		
		# 移动冰锥
		global_position.y += fall_distance - current_fall_distance
		current_fall_distance = fall_distance
		
		# 到达地面，销毁
		_destroy_icecone()
		return
	
	# 继续下落
	global_position.y += move_distance
	current_fall_distance = new_distance
	
	# 下落过程中检测碰撞（手动检测）
	_check_collision_during_fall()

# ========== 碰撞检测（更新版） ==========
func _check_collision_during_fall() -> void:
	if current_state != ConeState.FALLING or has_hit_player:
		return
	
	# 获取物理空间状态
	var space_state = get_world_2d().direct_space_state
	
	# 创建形状查询
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = global_transform
	query.collision_mask = 1  # 根据实际碰撞层调整，检测玩家层
	query.exclude = [self]    # 排除自身
	
	var results = space_state.intersect_shape(query)
	
	for result in results:
		var collider = result.collider
		
		# 如果碰撞体为空，跳过
		if collider == null:
			continue
		
		# 检测到玩家
		if collider.is_in_group("Player"):
			has_hit_player = true
			# 造成伤害
			if collider.has_method("take_damage"):
				collider.take_damage(ice_damage)
			# 销毁冰锥
			_destroy_icecone()
			return
		
		# 检测到其他物体（地面、墙体、平台等）
		# 包括 StaticBody2D 和 CharacterBody2D（非玩家）
		else:
			# 如果是物理体（StaticBody2D 或 CharacterBody2D）
			if collider is StaticBody2D or collider is CharacterBody2D:
				# 确保不是玩家（虽然前面已经判断过了，但为了安全再次确认）
				if not collider.is_in_group("Player"):
					_destroy_icecone()
					return
			
			# 如果是 TileMap（瓦片地图）
			elif collider is TileMap:
				_destroy_icecone()
				return

# ========== 销毁功能 ==========
func _destroy_icecone() -> void:
	if current_state == ConeState.DESTROYED:
		return
	
	current_state = ConeState.DESTROYED
	
	# 停止晃动动画
	if shake_tween != null:
		shake_tween.kill()
		shake_tween = null
	
	# 延迟一帧销毁，避免物理冲突
	await get_tree().process_frame
	queue_free()

# 外部调用销毁
func destroy_icecone() -> void:
	_destroy_icecone()

# ========== 重置功能（用于对象池） ==========
func reset_icecone() -> void:
	current_state = ConeState.IDLE
	is_triggered = false
	global_position = original_position
	current_fall_distance = 0.0
	has_hit_player = false
	
	if shake_tween != null:
		shake_tween.kill()
		shake_tween = null
	
	show()

# ========== 调试信息 ==========
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not has_node("Area2D"):
		warnings.append("缺少 Area2D 节点，无法检测玩家进入")
	if not has_node("CollisionShape2D"):
		warnings.append("缺少 CollisionShape2D 节点，无法进行碰撞检测")
	if not has_node("Sprite2D"):
		warnings.append("缺少 Sprite2D 节点，建议添加视觉显示")
	
	return warnings
