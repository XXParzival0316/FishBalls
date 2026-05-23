extends CharacterBody2D
# Author XXParzival

# 状态枚举
enum STATE{
	FLOOR,
	FALL,
}

const SPEED := 200.0
const JUMP_VELOCITY := -270.0
const GRAVITY := 1000.0

# 状态
var active_state := STATE.FLOOR
# 是否可以反弹
var can_rebound:bool = false
# 下落高度
var fall_height:float = 0.0


@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	
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
				if fall_height:
					# 地板高度
					var floor_height:float = position.y
					if floor_height > fall_height:
						if floor_height - fall_height >100:
							var bounce_height = (floor_height -fall_height) * 3
							if bounce_height < 800:
								bounce(bounce_height)
							else :
								bounce(800)
						else:
							print("高度差不足100，无法反弹")
							
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
					fall_height = position.y
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
	

func bounce(bounce_target:float) -> void:
	print("反弹高度为:",bounce_target)
	smoonth_scale(Vector2(0.5,0.5),0.25)
	velocity.y = -bounce_target
	can_rebound = false
	
func smoonth_scale(target_scale:Vector2,duration:float)->void:
	var tween := create_tween()
	tween.tween_property(self,"scale",target_scale,duration)


func _entered_water(body: Node2D) -> void:
	smoonth_scale(Vector2(1.0,1.0),0.75)
	can_rebound = true
	
