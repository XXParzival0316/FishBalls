extends Area2D

@export var platform : Platform





func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		platform.is_active = true 
