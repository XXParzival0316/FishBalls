# Author Baishu
extends Enemy

@export var current_enemy : Node2D 

func _enter_tree() -> void:
	super._enter_tree()
	normal_speed = 100
	chase_speed = 150

func _ready() -> void:
	super._ready()
	change_state(load("res://Script/Enemy/State/octopus/octopus_patrol_state.gd")) #启用patrol_state

func _physics_process(delta: float) -> void:
	super._physics_process(delta)

func _on_warning_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		current_enemy = body
		print(current_enemy.position)
		#dir = (current_enemy.global_position - global_position).normalized()
		losttime = 5
		
