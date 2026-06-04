# Author Baishu
#切换回PatrolState：get_parent().change_state(load("res://Script/Enemy/State/octopus/octopus_patrol_state.gd")  )
extends Node

var octopus : Enemy

func start():
	octopus = get_parent()
	print("播放警戒动画")
	octopus.is_move = false
	octopus.animated_sprite_2d.play("warning")
	await octopus.animated_sprite_2d.animation_finished
	octopus.is_move = true
	octopus.animated_sprite_2d.play("chase")
	octopus.now_speed = octopus.chase_speed
	octopus.waittime = 0
	

func _physics_process(delta: float) -> void:
	follow_player()
	if octopus.current_enemy == null:
		await get_tree().create_timer(1).timeout
		octopus.change_state(load("res://Script/Enemy/State/octopus/octopus_patrol_state.gd"))


	

func follow_player():
	if octopus.current_enemy == null:
		return
	if octopus.is_ground_ahead(octopus.dir.x) == true:
		octopus.wait_and_flip_direction(0)
		octopus.current_enemy = null
		return
	else:
		octopus.dir = (octopus.current_enemy.global_position - octopus.global_position).normalized()
		if octopus.current_enemy.global_position.x - octopus.global_position.x > 0 and octopus.facing_right == false and octopus.global_position.distance_to(octopus.current_enemy.global_position) > 10:
			octopus.wait_and_flip_direction(0.2)
		elif octopus.current_enemy.global_position.x - octopus.global_position.x < 0 and octopus.facing_right == true:
			octopus.wait_and_flip_direction(0.2)
