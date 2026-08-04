extends Camera2D

@export var maxZoom = 2.0
@export var minZoom = 0.5


func _process(delta: float) -> void:
	_refresh_camera()
	
func _refresh_camera() -> void:
	global_position = _calculate_position()
	zoom = _calculate_zoom()
	
func _calculate_zoom():
	var maxDistance = _get_max_player_distance()
	var zoomLevel = clamp(maxZoom - (maxDistance/500),minZoom,maxZoom)
	return Vector2(zoomLevel,zoomLevel)

func _get_max_player_distance():
	var maxDistance = 0.0
	var players = get_tree().get_nodes_in_group("Player")
	
	for player in players:
		for controlPlayer in players:
			var distance = player.global_position.distance_to(controlPlayer.global_position)
			
			if distance > maxDistance:
				maxDistance = distance

		return maxDistance

func _calculate_position():
	var players = get_tree().get_nodes_in_group("Player")
	var sumPosition = Vector2(0,0)
	
	for player in players:
		sumPosition += player.global_position
		
	return sumPosition / players.size()
