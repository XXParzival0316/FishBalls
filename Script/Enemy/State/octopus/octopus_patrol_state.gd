# Author Baishu
#切换到chasestate：get_parent().change_state(load("res://Script/Enemy/State/octopus/octopus_chase_state.gd"))
extends Node


func start():
	var octopus : Enemy = get_parent()
	octopus.now_speed = octopus.normal_speed
	octopus.animated_sprite_2d.play("walk")

func _physics_process(delta: float) -> void:
		pass
