extends CharacterBody2D
# Author XXParzival

# 状态枚举
enum STATE{
	FLOOR,
	FALL,
}

const SPEED := 300.0
const JUMP_VELOCITY := -400.0
const GRAVITY := 1000.0

var active_state := STATE.FLOOR

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("Left","Right")
	
	# 匹配状态
	match active_state:
		STATE.FLOOR:
			# 动画播放
			if direction:
				if direction == 1.0:
					animated_sprite_2d.flip_h = false
					animated_sprite_2d.play("Walk")
				else:
					animated_sprite_2d.flip_h = true
					animated_sprite_2d.play("Walk")
			else:
				animated_sprite_2d.play("Idle")
			velocity.x = direction * SPEED
			
			if Input.is_action_just_pressed("Down"):
				set_collision_mask_value(5,false)
				await get_tree().create_timer(0.2).timeout
				set_collision_mask_value(5,true)
				
			# 处理跳跃
			if Input.is_action_just_pressed("Jump"):
				velocity.y = JUMP_VELOCITY
			
			if not is_on_floor():
				active_state = STATE.FALL
		STATE.FALL:
			velocity.x = direction * SPEED
			velocity.y += GRAVITY * delta
			# TODO-下落动画


			if  is_on_floor():
				velocity.y = 0
				active_state = STATE.FLOOR
	
	move_and_slide()
