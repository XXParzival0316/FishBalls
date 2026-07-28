extends StaticBody2D

# ========== 全局可调参数 ==========
# 冰锥预制体资源
@export var ice_cone_scene: PackedScene
# 冰锥生成间隔范围（秒）- 每个识别点独立随机
@export var spawn_interval_min: float = 1.5
@export var spawn_interval_max: float = 4.0
# 单个冰锥存活最大时长（防止冰锥卡地图永久留存）
@export var cone_life_time: float = 6.0
# 本层踩冰伤害参数
@export var ice_damage: float = 10.0
@export var damage_interval: float = 0.5
@export var damage_enable: bool = true

# 生成点位集合（读取Icicle分组内全部节点）
var spawn_points: Array[Node] = []
var damage_cool_down: bool = false
# 存储每个识别点的计时器
var point_timers: Dictionary = {}
# 存储所有已生成的冰锥引用
var active_cones: Array[Node] = []

func _ready() -> void:
	# 从分组获取所有生成点
	spawn_points = get_tree().get_nodes_in_group("Icicle")
	
	# 为每个识别点创建独立的计时器
	for point in spawn_points:
		if point.is_inside_tree():
			_create_timer_for_point(point)
	
	# 绑定地面踩伤区域
	$HitArea.body_entered.connect(_on_player_step_in)
	$HitArea.body_exited.connect(_on_player_step_out)

# 为单个识别点创建计时器
func _create_timer_for_point(point: Node) -> void:
	if ice_cone_scene == null:
		return
		
	var timer = Timer.new()
	timer.wait_time = _get_random_interval()
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_spawn_ice_cone_at_point.bind(point))
	add_child(timer)
	
	# 存储计时器引用
	point_timers[point] = timer

# 获取随机生成间隔
func _get_random_interval() -> float:
	return randf_range(spawn_interval_min, spawn_interval_max)

# 在指定识别点生成单个冰锥
func _spawn_ice_cone_at_point(point: Node) -> void:
	# 校验节点是否还在场景树中
	if not point.is_inside_tree() or ice_cone_scene == null:
		return
		
	# 实例化冰锥
	var new_cone = ice_cone_scene.instantiate()
	new_cone.global_position = point.global_position
	
	# 添加到场景
	get_parent().call_deferred("add_child", new_cone)
	
	# 记录活动冰锥
	active_cones.append(new_cone)
	
	# 冰锥自动销毁机制（超时销毁）
	# 注意：SceneTreeTimer 无法手动停止，所以不需要存储引用
	get_tree().create_timer(cone_life_time).timeout.connect(_destroy_cone_with_weakref.bind(weakref(new_cone)))
	
	# 冰锥销毁时自动从活动列表移除
	if new_cone.has_signal("tree_exited"):
		new_cone.tree_exited.connect(_remove_cone_from_active.bind(new_cone))
	
	# 重置识别点计时器为新的随机间隔
	var point_timer = point_timers.get(point)
	if point_timer != null:
		point_timer.wait_time = _get_random_interval()
		point_timer.start()

# 使用弱引用销毁冰锥
func _destroy_cone_with_weakref(cone_ref: WeakRef) -> void:
	var cone = cone_ref.get_ref()
	if cone != null && cone.is_inside_tree():
		# 如果冰锥有销毁方法则调用，否则直接移除
		if cone.has_method("destroy_icecone"):
			cone.destroy_icecone()
		else:
			cone.queue_free()
		
		# 从活动列表中移除
		_remove_cone_from_active(cone)

# 从活动列表中移除冰锥
func _remove_cone_from_active(cone: Node) -> void:
	var index = active_cones.find(cone)
	if index != -1:
		active_cones.remove_at(index)

# ========== 手动控制方法 ==========
# 停止所有识别点的生成
func stop_spawning() -> void:
	for timer in point_timers.values():
		if timer != null:
			timer.stop()

# 恢复所有识别点的生成
func resume_spawning() -> void:
	for timer in point_timers.values():
		if timer != null:
			timer.wait_time = _get_random_interval()
			timer.start()

# 重置所有识别点的生成间隔
func reset_all_intervals() -> void:
	for timer in point_timers.values():
		if timer != null:
			timer.wait_time = _get_random_interval()
			timer.start()

# 立即销毁所有已生成的冰锥
func clear_all_cones() -> void:
	# 销毁所有冰锥
	for cone in active_cones:
		if cone != null && cone.is_inside_tree():
			if cone.has_method("destroy_icecone"):
				cone.destroy_icecone()
			else:
				cone.queue_free()
	active_cones.clear()

# 动态添加新的识别点（运行时）
func add_spawn_point(point: Node) -> void:
	if point not in spawn_points and point.is_inside_tree():
		spawn_points.append(point)
		_create_timer_for_point(point)

# 动态移除识别点（运行时）
func remove_spawn_point(point: Node) -> void:
	if point in spawn_points:
		spawn_points.erase(point)
		if point_timers.has(point):
			var timer = point_timers[point]
			if timer != null:
				timer.stop()
				timer.queue_free()
			point_timers.erase(point)

# ========== 地面踩伤逻辑 ==========
func _on_player_step_in(body: Node2D) -> void:
	if not damage_enable or damage_cool_down:
		return
	if body.is_in_group("Player"):
		_execute_damage(body)

func _on_player_step_out(body: Node2D) -> void:
	if body.is_in_group("Player"):
		damage_cool_down = false

func _execute_damage(player: Node2D) -> void:
	damage_cool_down = true
	if player.has_method("take_damage"):
		player.take_damage(ice_damage)
	await get_tree().create_timer(damage_interval).timeout
	damage_cool_down = false

# ========== 清理资源 ==========
func _exit_tree() -> void:
	# 停止并清理所有识别点计时器
	for timer in point_timers.values():
		if timer != null:
			timer.stop()
			timer.queue_free()
	point_timers.clear()
	
	# 销毁所有冰锥（SceneTreeTimer会自动清理，无需手动处理）
	for cone in active_cones:
		if cone != null && cone.is_inside_tree():
			if cone.has_method("destroy_icecone"):
				cone.destroy_icecone()
			else:
				cone.queue_free()
	active_cones.clear()
