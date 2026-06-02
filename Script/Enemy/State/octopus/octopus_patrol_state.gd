# Author Baishu
#切换到chasestate：get_parent().change_state(load("res://Script/Enemy/State/octopus/octopus_chase_state.gd"))
extends Node

var octopus : Enemy

func start():
	octopus = get_parent()
	octopus.now_speed = octopus.normal_speed
	octopus.animated_sprite_2d.play("walk")
	octopus.waittime = 2

func _physics_process(delta: float) -> void:
		find_player()

func find_player():
	if octopus.current_enemy != null:
		octopus.change_state(load("res://Script/Enemy/State/octopus/octopus_chase_state.gd"))
