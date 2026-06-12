extends Area2D

var full_polygon : PackedVector2Array
@export var hurting_player : Node2D
@export var is_extending : bool = true
var animated_sprite_2d : AnimatedSprite2D
var current_animation : String
var collision1 : CollisionShape2D
var collision2 : CollisionShape2D
var collision3 : CollisionShape2D
var collision4 : CollisionShape2D

func _enter_tree() -> void:
	animated_sprite_2d = $AnimatedSprite2D
	collision1 = $Collision1
	collision2 = $Collision2
	collision3 = $Collision3
	collision4 = $Collision4
func _ready():
	play_animation()
func _physics_process(delta: float) -> void:
	hurt_player()

func play_animation():  #用于循环动画的函数
	while true:
		if is_extending:
			animated_sprite_2d.play("extension")
			current_animation = animated_sprite_2d.animation
			animate_collision()
			await animated_sprite_2d.animation_finished
			is_extending = false
		else:
			animated_sprite_2d.play("shrink")
			current_animation = animated_sprite_2d.animation
			animate_collision()
			await animated_sprite_2d.animation_finished
			is_extending = true
func animate_collision():
	while animated_sprite_2d.is_playing():
		var frame_count = animated_sprite_2d.sprite_frames.get_frame_count(current_animation)
		var current_frame = animated_sprite_2d.frame
		var percent = float(current_frame) / float(frame_count - 1)
		if not is_extending:
			percent = 1.0 - percent
		if percent >= 0 and percent < 0.25:
			enable_collision_1()
		elif percent >= 0.25 and percent < 0.5:
			enable_collision_2()
		elif percent >= 0.5 and percent < 0.75:
			enable_collision_3()
		elif percent >= 0.75 and percent <= 1.0:
			enable_collision_4()
		await get_tree().process_frame
func enable_collision_1():
	collision1.disabled = false
	collision2.disabled = true
	collision3.disabled = true
	collision4.disabled = true
func enable_collision_2():
	collision1.disabled = false
	collision2.disabled = false
	collision3.disabled = true
	collision4.disabled = true
func enable_collision_3():
	collision1.disabled = false
	collision2.disabled = false
	collision3.disabled = false
	collision4.disabled = true
func enable_collision_4():
	collision1.disabled = false
	collision2.disabled = false
	collision3.disabled = false
	collision4.disabled = false

func hurt_player():
	if hurting_player != null:
		if hurting_player.is_in_group("Player"):
			if hurting_player.has_method("take_damage") and not hurting_player.invincible:
				hurting_player.take_damage(10)
				var direction = 1 if hurting_player.global_position.x - global_position.x > 0 else -1
				hurting_player.apply_knockback(600 * direction)
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		print("检测到")
		hurting_player = body
func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		hurting_player = null
