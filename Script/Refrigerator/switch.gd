extends Area2D

@export var platform : Platform
@export var door1 : Doors
@export var door2 : Doors
@export var door3 : Doors
@export var door4 : Doors
var has_trigger = false
var animatied_sprite_2d : AnimatedSprite2D

func _enter_tree() -> void:
	animatied_sprite_2d = $AnimatedSprite2D
	animatied_sprite_2d.play("off")


func _on_body_entered(body: Node2D) -> void:
	if has_trigger:
		return
	else:
		if body.is_in_group("Player"):
			has_trigger = true
			animatied_sprite_2d.play("on")
			$AudioStreamPlayer2D.play()
			if platform != null:
				platform.is_active = true 
			if door1 != null:
				door1.is_close = not door1.is_close
			if door2 != null:
				door2.is_close = not door2.is_close
			if door3 != null:
				door3.is_close = not door3.is_close
			if door4 != null:
				door4.is_close = not door4.is_close
