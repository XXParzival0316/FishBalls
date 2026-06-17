class_name Platform
extends CharacterBody2D

@export var lift_dis: float 
@export var lift_speed: float

var is_active: bool = false       
var going_up: bool = true          #true=上升，false=下降
var top_y: float
var bottom_y: float

func _ready():
	bottom_y = position.y
	top_y = position.y - lift_dis

# 外部调用：启动
func activate():
	is_active = true
	going_up = true  # 从上升开始

# 外部调用：停止
func deactivate():
	is_active = false

func _physics_process(delta):
	if not is_active:
		return
	
	var target_y = top_y if going_up else bottom_y
	position.y = lerp(position.y, target_y, delta * lift_speed)
	
	# 到达检测并切换方向
	if abs(position.y - target_y) < 0.1:
		position.y = target_y
		going_up = not going_up  # 切换方向
		#print("到达", "顶部" if going_up == false else "底部")
