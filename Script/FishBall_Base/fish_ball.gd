extends CharacterBody2D
# Author XXParzival

# 状态枚举
enum STATE{
	FLOOR,
	FALL,
}
signal interact

const SPEED := 200.0
const JUMP_VELOCITY := -270.0
const GRAVITY := 1000.0
# 吸水持续状态
const BOUNCE_TIME:float = 15.0

# 状态
var active_state := STATE.FLOOR
# 是否可以反弹
var can_rebound:bool = false
# 下落高度
var fall_height:float = 0.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var timer:Timer = $Timer
# 粒子特效
@onready var water_drop_particles: CPUParticles2D = $Particles/WaterDrop
@onready var water_explosion_particles: CPUParticles2D = $Particles/WaterExplosion



func _ready() -> void:
	pass
	


func _physics_process(delta: float) -> void:
	# 检测按下互动,发射型号
	if Input.is_action_just_pressed("Interact"):
		interact.emit()

	var direction := Input.get_axis("Left","Right")
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
			velocity.x = direction * SPEED
			
			if Input.is_action_just_pressed("Down"):
				set_collision_mask_value(5,false)
				await get_tree().create_timer(0.2).timeout
				set_collision_mask_value(5,true)
			
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
				
			velocity.x = direction * SPEED
			velocity.y += GRAVITY * delta
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
	move_and_slide()
	
	
	
	# 滴水粒子开关
	if can_rebound:
		water_drop_particles.emitting = true
	else:
		water_drop_particles.emitting = false

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


func _entered_water(body: Node2D) -> void:
	timer.set_wait_time(BOUNCE_TIME)
	timer.start()
	smoonth_scale(Vector2(1.0,1.0),0.75)
	can_rebound = true
	


func _on_timer_timeout() -> void:
	smoonth_scale(Vector2(0.5,0.5),0.75)
	can_rebound = false
