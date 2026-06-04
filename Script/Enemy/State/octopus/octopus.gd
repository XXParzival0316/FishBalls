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


func _on_wall_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		wait_and_flip_direction(waittime)
		current_enemy = null


func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		last_animation = animated_sprite_2d.animation
		animated_sprite_2d.play("attack")
		if body.has_method("take_damage") and body.invincible == false:
			body.take_damage(10)
			if body.global_position.x - global_position.x > 0:
				body.apply_knockback(600)   # 向右击退
			else:
				body.apply_knockback(-600)  # 向左击退


func _on_attack_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animated_sprite_2d.play(last_animation)
