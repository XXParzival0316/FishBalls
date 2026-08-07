extends StaticBody2D

@export_group("基本属性")
## 鱼车移动速度
@export var move_speed: float = 500
@export_group("受到技能影响参数")
## 被芥末酱打到后的晕厥时间
@export var wasabi_syncope_time:float = 5.0
## 受到冰霜行者影响的持续时间
@export var icewalk_time:float = 10.0
## 受到冰霜行者影响后，鱼车的移动速度
@export var icewalk_fishcar_speed:float = 200
@onready var rigth_bar_col: CollisionShape2D = $RightBar/CollisionShape2D
@onready var left_bar_col: CollisionShape2D = $LeftBar/CollisionShape2D
@onready var left_bound: Node2D = $LeftBound
@onready var right_bound: Node2D = $RightBound
@onready var marker_2d: Marker2D = $Marker2D
var is_hit:bool = false
# 记录鱼车原始移速
var origin_speed:float
var move_dir: float = 1.0  # 1向右，-1向左
# 记录鱼车是否有被冰霜行者影响过
var icewalk_effected:bool = false
var left_bound_x:float
var right_bound_x:float
# 玩家TP位置
var tp_position:Vector2

func _ready() -> void:
	left_bound_x = left_bound.global_position.x
	right_bound_x = right_bound.global_position.x
	tp_position = marker_2d.global_position
	rigth_bar_col.disabled = true
	left_bar_col.disabled = true
	origin_speed = move_speed

	# 自动播放鱼车动画
	$AnimatedSprite2D.play()

func _physics_process(delta: float) -> void:
	# 水平移动
	position.x += move_speed * move_dir * delta
	# 碰到左边界向右
	if position.x < left_bound_x:
		move_dir = 1.0
	# 碰到右边界向左
	if position.x > right_bound_x:
		move_dir = -1.0
		
	# 跟随移动方向翻转鱼车
	$AnimatedSprite2D.flip_h = move_dir < 0

func take_damage(damage):
	if not is_hit:
		$AudioStreamPlayer2D.play()
		is_hit = true	
		modulate = Color(1.0, 0.0, 0.0, 1.0)
		move_speed = 0
		$HitDetech.monitoring = false
		$AnimatedSprite2D.pause()
		$IceWalkDetech.monitoring = true
		await get_tree().create_timer(wasabi_syncope_time).timeout
		is_hit = false
		$AnimatedSprite2D.play()
		$IceWalkDetech.monitoring = false
		$HitDetech.monitoring = true
		
		# 要是没受ic影响
		if not icewalk_effected:
			move_speed = origin_speed
			modulate = Color(1.0, 1.0, 1.0, 1.0)

# 传送玩家
func tp_Player(body:Node2D) -> void:
	body.global_position = tp_position

# 撞到玩家传送
func _on_hit_detech_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		tp_Player(body)

# 受到冰霜行者的影响的效果
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
