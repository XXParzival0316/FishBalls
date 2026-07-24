class_name Doors
extends CharacterBody2D

var now_pos
var target_pos
@export var move_dis : float
@export var is_close = false
@export var speed : float
var is_close_prev = false

func _enter_tree() -> void:
	now_pos = position
	target_pos = now_pos

func _physics_process(delta: float) -> void:
	change()
	if  is_close:
		position = lerp(now_pos,target_pos,delta * speed)
		now_pos = position
	else:
		position = lerp(now_pos,target_pos,delta * speed)
		now_pos = position
		
func change():
	if is_close != is_close_prev:
		is_close_prev = is_close
		# 状态改变时，重新计算目标位置
		if is_close:
			target_pos.y -= move_dis
		else:
			target_pos.y += move_dis
