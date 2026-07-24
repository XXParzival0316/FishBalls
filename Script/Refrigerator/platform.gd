class_name Platform
extends CharacterBody2D

@export var y_move_dis: float 
@export var x_move_dis: float

@export var is_active: bool = false
@export var lift_speed: float
@export var loop : bool = false
@export var multiple_moves : bool
@export var is_destory : bool     
var going_up: bool = true

var top_y: float
var bottom_y: float
var start_x: float          # 记录起始X位置
var target_x: float         # 目标X位置

# 移动阶段枚举
enum MovePhase { VERTICAL, HORIZONTAL, DONE }
var current_phase: MovePhase = MovePhase.VERTICAL

func _ready():
	bottom_y = position.y
	top_y = position.y - y_move_dis
	start_x = position.x
	target_x = start_x + x_move_dis

func activate():
	is_active = true
	going_up = true
	current_phase = MovePhase.VERTICAL  # 从垂直阶段开始

func _physics_process(delta):
	if is_destory and is_active:
		queue_free()
	if not is_active:
		return
	
	match current_phase:
		MovePhase.VERTICAL:
			platform_move_y(delta)
		MovePhase.HORIZONTAL:
			platform_move_x(delta)
		MovePhase.DONE:
			pass  # 移动完成，什么都不做

func platform_move_y(delta):
	var target_y = top_y if going_up else bottom_y
	position.y = lerp(position.y, target_y, delta * lift_speed)
	
	# 到达检测
	if abs(position.y - target_y) < 0.1:
		position.y = target_y
		
		if loop:
			# 循环模式：切换方向，继续垂直移动
			going_up = not going_up
		elif multiple_moves:
			# 非循环 + 允许多段移动 → 切换到水平阶段
			current_phase = MovePhase.HORIZONTAL
		# 如果既不是循环也不是多段移动，则结束

func platform_move_x(delta):
	position.x = lerp(position.x, target_x, delta * lift_speed)
	
	# 到达检测
	if abs(position.x - target_x) < 0.1:
		position.x = target_x
		current_phase = MovePhase.DONE  # 水平移动完成
		#print("全部移动完成")
