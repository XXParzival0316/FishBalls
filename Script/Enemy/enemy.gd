# Author Baishu
extends CharacterBody2D

class_name Enemy

#基本参数
var health : int = 100  #血量
var normal_speed :float #正常速度
var chase_speed : float #追击时速度
var now_speed : float #当前速度
var dir : Vector2
var gravity = 1000
var on_ground 
var next_wall
#储存玩家
var player = null

#状态机
@onready var state_machine : Node = $StateMachine

#检测地面
@export var ground_check_distance : float = 30.0  # 前方检测距离
@export var ground_check_height : float = 10.0    # 向下检测高度

#组件
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ground_checker = $GroundCheck
@onready var wall_checker = $WallChecker

func _enter_tree() -> void: #start
	dir.x = $".".scale.x
	on_ground = true
	next_wall = false

func _ready() -> void: #awake
	ground_checker.collision_mask = 1
	change_state(load("res://Script/Enemy/State/octopus/octopus_patrol_state.gd")) #启用patrol_state
	state_machine.set_physics_process(true)

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move(delta)

	
func move(delta):
	velocity.x = now_speed * dir.x
	if not is_on_floor():
		velocity.y += gravity * delta #加重力
	move_and_slide()
	
func _on_ground_check_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		on_ground = true
		pass

func _on_ground_check_body_exited(body: Node2D) -> void:#检测前方是否为悬崖
	if body is TileMapLayer:
		if on_ground:
			flip_direction()
			on_ground = false

func _on_wall_checker_body_entered(body: Node2D) -> void:#检测是否撞墙
	if body is TileMapLayer:
			flip_direction()

func flip_direction() -> void:
	scale.x *= -1
	dir *= -1

func change_state(script : GDScript)-> void:#用于切换状态
	state_machine.set_script(script)
	state_machine.start()
	if state_machine.has_method("exit"):
		state_machine.exit()
