# Author Baishu
extends Node

func start():
	get_parent().modulate = Color(0.0, 0.584, 0.778, 1.0)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_left"):
		get_parent().change_state(load("res://Script/Enemy/State/octopus/octopus_patrol_state.gd")  )
