extends Area2D

var player:Player


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		body.take_damage(10)
		restore_player()
		body.position = $Node2D.global_position
		
func restore_player():
	player.can_rebound = false
	player.scale = Vector2(0.8,0.8)
