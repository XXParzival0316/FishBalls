extends CharacterBody2D
# Author XXParzival

# 状态枚举
enum STATE{
	FLOOR,
	JUMP,
	FALL,
}

signal interact
signal dead

const SPEED := 150.0
const JUMP_VELOCITY := -270.0
# 吸水持续状态
const BOUNCE_TIME:float = 15.0

# 血量
var HP:float = 100.0
# 状态
var active_state := STATE.FLOOR
# 是否可以反弹
var can_rebound:bool = false
# 下落高度
var fall_height:float = 0.0
# 是否为克隆体
var is_clone:bool = false
# 击退系统(Baishu)
var knockback_velocity_x: float = 0.0
var knockback_friction: float = 0.6 # 每帧衰减速度
# 受伤无敌时间(Baishu)
var invincible: bool = false
var invincible_time : float = 0.8
# 开启克隆
@export var clone:bool = false
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer:Timer = $Timer
# 粒子特效
@onready var water_drop_particles: CPUParticles2D = $Particles/WaterDrop
@onready var water_explosion_particles: CPUParticles2D = $Particles/WaterExplosion

func _ready() -> void:
	if clone:		
		var target:Node2D=$Node2D
		var fb_tscn:PackedScene = load("res://Scenes/FishBall/fish_ball.tscn")
		var fb_inst:CharacterBody2D = fb_tscn.instantiate()
		fb_inst.name = "FishBall_Clone"
		# 如果你看到这行报错，需要往鱼蛋下面挂一个Node2D节点用来确定克隆鱼蛋生成位置
		fb_inst.position = target.global_position
		fb_inst.is_clone = true
		get_tree().current_scene.call_deferred("add_child",fb_inst)

func _physics_process(delta: float) -> void:
	# 检测按下互动,发射型号
	if Input.is_action_just_pressed("Interact"):
		interact.emit()
	if not is_clone:
		var direction := Input.get_axis("Left","Right")
		match_active_state(delta,direction)
	else:
		var direction := Input.get_axis("Right","Left")
		match_active_state(delta,direction)
	
	move_and_slide()
	
	# 滴水粒子开关
	if can_rebound:
		water_drop_particles.emitting = true
	else:
		water_drop_particles.emitting = false

func match_active_state(delta:float,direction:float) -> void:
	# 匹配状态
	match active_state:
		STATE.FLOOR:
			# 动画播放
			if direction:
				# 处理动画翻转
				if direction == 1.0:
					animated_sprite_2d.flip_h = false
				else:
					animated_sprite_2d.flip_h = true
				animated_sprite_2d.play("Walk")
			else :
				animated_sprite_2d.play("Idle")
			#velocity.x = direction * SPEED
			if abs(knockback_velocity_x) > 1:
				velocity.x = knockback_velocity_x
				knockback_velocity_x *= knockback_friction  # 逐渐衰减
			else:
				knockback_velocity_x = 0
				velocity.x = direction * SPEED
			if can_rebound:
				# 下落高度不为0才判断
				if fall_height:
					# 检测地板高度
					var floor_height:float = position.y
					# 地板高度要低于下落高度才进行判断
					if floor_height > fall_height:
						# 要到一定的高度差才反弹
						if floor_height - fall_height >100:
							var bounce_height = (floor_height -fall_height) * 3
							if bounce_height < 800:
								bounce(bounce_height)
							else :
								bounce(800)
						else:
							print("高度差不足100，无法反弹")
					# 重置下落高度为0
					fall_height = 0.0
			# 处理跳跃
			if Input.is_action_just_pressed("Jump"):
				active_state = STATE.JUMP
				
			# 状态变成下落
			if not is_on_floor():
				active_state = STATE.FALL
				
		STATE.JUMP:
			animated_sprite_2d.play("Jump")
			velocity.y = JUMP_VELOCITY
				
			if not is_on_floor():
				active_state = STATE.FALL
				
		STATE.FALL:
			# 记录吸水后下落高度
			if can_rebound:
				if not fall_height:
					# 初始化下落高度
					fall_height = position.y
				# 记录最高下落高度
				if fall_height > position.y:
					fall_height = position.y			
				
			#velocity.x = direction * SPEED
			if abs(knockback_velocity_x) > 1:
				velocity.x = knockback_velocity_x
				knockback_velocity_x *= knockback_friction
			else:
				knockback_velocity_x = 0
				velocity.x = direction * SPEED
			velocity += get_gravity() * delta
			# 动画处理
			# 处理动画翻转
			if direction:
				if direction == 1.0:
					animated_sprite_2d.flip_h = false
				else:
					animated_sprite_2d.flip_h = true
			# 处理跳跃和下落
			if velocity.y < 0.0:
				animated_sprite_2d.play("Jump")
			else :
				animated_sprite_2d.play("Fall")

			if  is_on_floor():
				velocity.y = 0
				active_state = STATE.FLOOR
# 反弹
func bounce(bounce_target:float) -> void:
	water_drop_particles.emitting = false
	print("反弹高度为:",bounce_target)
	smoonth_scale(Vector2(0.5,0.5),0.25)
	velocity.y = -bounce_target
	water_explosion_particles.emitting = true	
	can_rebound = false
	
func smoonth_scale(target_scale:Vector2,duration:float)->void:
	var tween := create_tween()
	tween.tween_property(self,"scale",target_scale,duration)

# 受伤
func take_damage(damage:float):
	if invincible == false:
		invincible = true
		HP -= damage
		print(name,"受到:",damage,"点伤害")
		if HP <= 0.0:
			print(name,"死了")
			dead.emit()
			queue_free()
			return
		await get_tree().create_timer(invincible_time).timeout
		invincible = false
func apply_knockback(force_x: float):
	knockback_velocity_x = force_x

func _entered_water(body: Node2D) -> void:
	timer.set_wait_time(BOUNCE_TIME)
	timer.start()
	smoonth_scale(Vector2(1.0,1.0),0.75)
	can_rebound = true
	
func _on_timer_timeout() -> void:
	smoonth_scale(Vector2(0.5,0.5),0.75)
	can_rebound = false
