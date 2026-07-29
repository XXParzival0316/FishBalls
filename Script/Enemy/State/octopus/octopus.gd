# Author Baishu
extends Enemy

var current_enemy : Node2D 
var hurting_player : Node2D
func _enter_tree() -> void:
	super._enter_tree()
	normal_speed = 100
	chase_speed = 150

func _ready() -> void:
	super._ready()
	change_state(load("res://Script/Enemy/State/octopus/octopus_patrol_state.gd")) #启用patrol_state

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	hurt_player()

func _on_warning_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		current_enemy = body
		print(current_enemy.position)


func _on_wall_checker_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		wait_and_flip_direction(waittime)
		current_enemy = null
	elif body.is_in_group("Wall"):
		wait_and_flip_direction(waittime)
		current_enemy = null
		
func _on_attack_area_body_entered(body: Node2D) -> void:
	hurting_player = body

func _on_attack_area_body_exited(body: Node2D) -> void:
	hurting_player = null
	if body.is_in_group("Player"):
		animated_sprite_2d.play(last_animation)


func hurt_player():
	if hurting_player != null:
		if hurting_player.is_in_group("Player"):
			last_animation = animated_sprite_2d.animation
			animated_sprite_2d.play("attack")
			if hurting_player.has_method("take_damage") and hurting_player.invincible == false:
				hurting_player.take_damage(10)
				if hurting_player.global_position.x - global_position.x > 0:
					hurting_player.apply_knockback(600)   # 向右击退
				else:
					hurting_player.apply_knockback(-600)  # 向左击退
	
