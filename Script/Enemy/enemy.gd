# Author Baishu
extends CharacterBody2D

class_name Enemy

#基本参数
var health : int = 100  #血量
var normal_speed :float #正常速度吗
var chase_speed : float #追击时速度
var now_speed : float #当前速度
var dir : Vector2
var gravity = 1000
var on_ground 
var next_wall
var last_animation : String = ""
var facing_right = true
#储存玩家
var player = null

#计时器
var waittime : float  
var losttime : float
var is_flipping : bool = false

#状态
var is_move : bool = true
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
	state_machine.set_physics_process(true)
	Ignore_player_collision()

func _process(delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	move(delta)
	if not is_flipping and is_ground_ahead(dir.x):
		wait_and_flip_direction(waittime)

func move(delta):
	if is_move == true:
		velocity.x = now_speed * dir.x
		move_and_slide()
	if not is_on_floor():
		velocity.y += gravity * delta #加重力

func is_ground_ahead(direction: int) -> bool:
	var dir_int = 0
	if direction > 0:
		dir_int = 1
	elif direction < 0:
		dir_int = -1
	if dir_int == 0:
		dir_int = 1 if facing_right else -1	
	var ray_start = global_position + Vector2(dir_int * 10, 0)
	var ray_end = ray_start + Vector2(dir_int * 15, 30)
	var query = PhysicsRayQueryParameters2D.create(ray_start, ray_end)
	query.collision_mask = 1 
	var result = get_world_2d().direct_space_state.intersect_ray(query)
	return result.is_empty()

func change_state(script : GDScript)-> void:#用于切换状态
	state_machine.set_script(script)
	state_machine.start()
	if state_machine.has_method("exit"):
		state_machine.exit()

func wait_and_flip_direction(waittime):
	#print("wait")
	if is_flipping:  # 防止重复调用
		return
	is_move = false
	is_flipping = true
	last_animation = animated_sprite_2d.animation
	animated_sprite_2d.play("idle")
	await get_tree().create_timer(waittime).timeout
	scale.x *= -1
	dir *= -1
	facing_right = not facing_right
	animated_sprite_2d.play(last_animation)
	is_move = true
	is_flipping = false
	
func Ignore_player_collision():
	await get_tree().process_frame
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		add_collision_exception_with(player)
