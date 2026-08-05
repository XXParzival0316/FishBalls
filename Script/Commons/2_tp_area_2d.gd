extends Area2D



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.take_damage(10)
		tp_2Players()
		
func tp_2Players() -> void:
	var player_arr = get_tree().get_nodes_in_group("Player")
	for player in player_arr:
		if player.name == "FishBall":
			player.position = $Node2D.global_position
		if player.name == "FishBall_Clone":
			player.position = $Marker2D.global_position
	
		
