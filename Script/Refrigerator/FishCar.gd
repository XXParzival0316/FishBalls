extends StaticBody2D

@export_group("基本属性")
## 鱼车移动速度
@export var move_speed: float = 500
@export var left_bound_x: float = -50.0
@export var right_bound_x: float = 300.0

@export_group("受到技能影响参数")
## 被芥末酱打到后的晕厥时间
@export var wasabi_syncope_time:float = 5.0
## 受到冰霜行者影响的持续时间
@export var icewalk_time:float = 10.0
## 受到冰霜行者影响后，鱼车的移动速度
@export var icewalk_fishcar_speed:float = 200
@onready var rigth_bar_col: CollisionShape2D = $RightBar/CollisionShape2D
@onready var left_bar_col: CollisionShape2D = $LeftBar/CollisionShape2D

# 记录鱼车是否有被冰霜行者影响过
var icewalk_effected:bool = false


# 记录鱼车原始移速
var origin_speed:float
var move_dir: float = -1.0  # 1向右，-1向左
var origin_y: float

func _ready() -> void:
	rigth_bar_col.disabled = true
	left_bar_col.disabled = true
	origin_speed = move_speed
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

func take_damage(damage):
	print("鱼车被击中")
	modulate = Color(1.0, 0.0, 0.0, 1.0)
	move_speed = 0
	$HitDetech.monitoring = false
	$AnimatedSprite2D.pause()
	$IceWalkDetech.monitoring = true
	await get_tree().create_timer(wasabi_syncope_time).timeout
	$AnimatedSprite2D.play()
	$IceWalkDetech.monitoring = false
	$HitDetech.monitoring = true
	# 要是没受ic影响
	if not icewalk_effected:
		move_speed = origin_speed
		modulate = Color(1.0, 1.0, 1.0, 1.0)

# 传送玩家
func tp_Player(body:Node2D) -> void:
	body.position = $Marker2D.global_position
	
# 撞到玩家传送
func _on_hit_detech_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		tp_Player(body)

func used_icewalk() -> void:
	# 受到过影响后不再执行
	if not icewalk_effected:
		icewalk_effected = true
		move_speed = icewalk_fishcar_speed
		modulate = Color(1.0, 0.0, 1.0, 1.0)
		$HitDetech.monitorable = false
		rigth_bar_col.disabled = false
		left_bar_col.disabled = false
		await get_tree().create_timer(icewalk_time).timeout
		print("你好")
		icewalk_effected = false
		$HitDetech.monitorable = true
		rigth_bar_col.disabled = true
		left_bar_col.disabled = true
		modulate = Color(1.0, 1.0, 1.0, 1.0)
		move_speed = origin_speed
		
	
	
# 检测玩家时候使用冰霜行者
func _on_ice_walk_detech_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_signal("using_icewalk"):
		if not body.using_icewalk.has_connections():
			body.using_icewalk.connect(used_icewalk)
		
func _on_ice_walk_detech_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player") and body.has_signal("using_icewalk"):
		if body.using_icewalk.has_connections():
			body.using_icewalk.disconnect(used_icewalk)
