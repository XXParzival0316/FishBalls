extends StaticBody2D

# ========== 可调参数 ==========
# 动画时间参数（秒）
@export var delay_before_move: float = 1.0      # 触发后延迟时间（顶部等待）
@export var move_down_distance: float = 20.0   # 下移距离（像素）
@export var move_duration: float = 0.5          # 下移动画持续时间
@export var stay_down_duration: float = 1.0     # 底部停留时间
@export var return_duration: float = 0.5        # 回位动画持续时间
@export var stay_up_duration: float = 1       # 顶部停留时间（循环间隔）

# 伤害参数（参考冰层代码）
@export var damage_amount: float = 10.0         # 伤害值
@export var damage_interval: float = 0.5        # 伤害间隔
@export var damage_enable: bool = true          # 是否启用伤害

# 自动触发参数
@export var auto_start: bool = true             # 是否自动开始循环

# ========== 内部状态 ==========
var original_position: Vector2                  # 原始位置（全局坐标）
var target_down_position: Vector2               # 下移目标位置
var is_moving: bool = false                     # 是否正在移动
var is_down: bool = false                       # 是否处于底部
var damage_cool_down: bool = false              # 伤害冷却
var is_running: bool = false                    # 是否正在运行循环
var loop_timer: Timer = null                    # 循环计时器

# 节点引用
@onready var hit_area: Area2D = $HitArea
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# ========== 生命周期 ==========
func _ready() -> void:
	# 保存原始位置（整个节点的全局位置）
	original_position = global_position
	# 计算目标位置（整个节点向下移动指定距离）
	target_down_position = original_position + Vector2(0, move_down_distance)
	
	# 绑定伤害检测信号
	if hit_area:
		hit_area.body_entered.connect(_on_hit_area_body_entered)
		hit_area.body_exited.connect(_on_hit_area_body_exited)
	
	# 自动开始循环
	if auto_start:
		start_loop()

# ========== 循环控制 ==========
# 开始循环
func start_loop() -> void:
	if is_running:
		return
	is_running = true
	_loop_spike()

# 停止循环
func stop_loop() -> void:
	is_running = false
	# 停止所有动画
	var tweens = get_tree().get_nodes_in_group("tween")
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
	
	# 回到原始位置
	global_position = original_position
	is_moving = false
	is_down = false
	
	# 停止计时器
	if loop_timer:
		loop_timer.stop()

# 主循环
func _loop_spike() -> void:
	while is_running and is_inside_tree():
		# 等待顶部停留时间
		if stay_up_duration > 0:
			await get_tree().create_timer(stay_up_duration).timeout
		
		if not is_running or not is_inside_tree():
			break
		
		# 下移
		is_moving = true
		is_down = true
		var tween = create_tween()
		tween.tween_property(self, "global_position", target_down_position, move_duration)
		await tween.finished
		
		if not is_running or not is_inside_tree():
			break
		
		is_moving = false
		
		# 底部停留
		if stay_down_duration > 0:
			await get_tree().create_timer(stay_down_duration).timeout
		
		if not is_running or not is_inside_tree():
			break
		
		# 回位
		is_moving = true
		is_down = false
		tween = create_tween()
		tween.tween_property(self, "global_position", original_position, return_duration)
		await tween.finished
		
		if not is_running or not is_inside_tree():
			break
		
		is_moving = false

# ========== 手动触发（保留单次触发功能） ==========
# 触发冰刺动画（单次，不影响循环）
func trigger_spike() -> void:
	if is_moving or is_running:
		return  # 正在运动中，忽略新触发
	
	is_moving = true
	_animate_spike()

# 执行单次冰刺动画
func _animate_spike() -> void:
	# 阶段1：延迟后下移
	await get_tree().create_timer(delay_before_move).timeout
	
	if not is_inside_tree():
		return
	
	# 阶段2：下移动画
	is_down = true
	var tween = create_tween()
	tween.tween_property(self, "global_position", target_down_position, move_duration)
	await tween.finished
	
	if not is_inside_tree():
		return
	
	# 阶段3：底部停留
	await get_tree().create_timer(stay_down_duration).timeout
	
	if not is_inside_tree():
		return
	
	# 阶段4：回位动画
	is_down = false
	tween = create_tween()
	tween.tween_property(self, "global_position", original_position, return_duration)
	await tween.finished
	
	if not is_inside_tree():
		return
	
	is_moving = false

# ========== 伤害逻辑 ==========
func _on_hit_area_body_entered(body: Node2D) -> void:
	if not damage_enable or damage_cool_down:
		return
	if body.is_in_group("Player"):
		_execute_damage(body)

func _on_hit_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		damage_cool_down = false

func _execute_damage(player: Node2D) -> void:
	damage_cool_down = true
	if player.has_method("take_damage"):
		player.take_damage(damage_amount)
	await get_tree().create_timer(damage_interval).timeout
	damage_cool_down = false

# ========== 辅助方法 ==========
# 重置到原始位置
func reset_immediate() -> void:
	# 停止所有动画
	var tweens = get_tree().get_nodes_in_group("tween")
	for tween in tweens:
		if tween.is_valid():
			tween.kill()
	
	global_position = original_position
	is_moving = false
	is_down = false

# 获取当前状态
func is_spike_active() -> bool:
	return is_moving or is_down

func is_spike_moving() -> bool:
	return is_moving

func is_spike_down() -> bool:
	return is_down

# 设置伤害参数
func set_damage(amount: float, interval: float = 0.5) -> void:
	damage_amount = amount
	damage_interval = interval

# 启用/禁用伤害
func set_damage_enabled(enabled: bool) -> void:
	damage_enable = enabled

# 更新移动距离（运行时修改）
func set_move_distance(distance: float) -> void:
	move_down_distance = distance
	target_down_position = original_position + Vector2(0, move_down_distance)

# ========== 调试信息 ==========
func _get_configuration_warnings() -> PackedStringArray:
	var warnings: PackedStringArray = []
	
	if not has_node("HitArea"):
		warnings.append("缺少 HitArea 节点，无法检测伤害")
	if not has_node("Sprite2D"):
		warnings.append("缺少 Sprite2D 节点，建议添加视觉显示")
	
	return warnings
