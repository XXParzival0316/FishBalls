extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(10)
		body.position = $Node2D.global_position
