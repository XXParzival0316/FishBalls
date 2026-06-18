extends Area2D

@export var platform : Platform

var animatied_sprite_2d : AnimatedSprite2D

func _enter_tree() -> void:
	animatied_sprite_2d = $AnimatedSprite2D
	animatied_sprite_2d.play("off")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		animatied_sprite_2d.play("on")
		platform.is_active = true 
