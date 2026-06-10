extends Area2D

@export var  extension_length : float #当前长度
@export var max_extension_length : float #最大伸缩长度
@export var extension_coefficient : float #伸缩系数，越大伸缩的速度越快
@export var min_extension_length : float #最小伸缩长度
var hurting_player : Node2D
var is_extending : bool
var animated_sprite_2d : AnimatedSprite2D
func _physics_process(delta: float) -> void:
	extension()
	hurt_player()
	
func _enter_tree() -> void:
	animated_sprite_2d = $AnimatedSprite2D
	animated_sprite_2d.play("default")
	
func hurt_player():
	if hurting_player != null:
		if hurting_player.is_in_group("Player"):
			if hurting_player.has_method("take_damage") and hurting_player.invincible == false:
				hurting_player.take_damage(10)
				if hurting_player.global_position.x - global_position.x > 0:
					hurting_player.apply_knockback(600)   # 向右击退
				else:
					hurting_player.apply_knockback(-600)  # 向左击退
func extension():
	if is_extending:
		extension_length += extension_coefficient
		if extension_length >= max_extension_length:
			extension_length = max_extension_length
			is_extending = false
	else:
		extension_length -= extension_coefficient
		if extension_length <= min_extension_length:
			extension_length = min_extension_length
			is_extending = true
	#scale.y = extension_length


func _on_body_entered(body: Node2D) -> void:
	hurting_player = body


func _on_body_exited(body: Node2D) -> void:
	hurting_player = null
