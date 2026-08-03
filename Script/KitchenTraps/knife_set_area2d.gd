extends Area2D
# Author Baishu

@onready var central_point : Vector2 = $Node2D.global_position
var is_in_area2d : bool = false
var player = null
var player_position : Vector2 
var max_speed = 5
var base_speed = 1
var coefficient : float = 0.0005 #旋转系数，这个越大，转的越快
var max_rotation : float = 30

func _ready() -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#print("is player")
		is_in_area2d = true
		player = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		#print("is player")
		is_in_area2d = false
		player = null

func get_angular_speed (distance : float) -> float:
	var speed = coefficient * distance
	return speed


func _process(delta: float) -> void:
	#print(central_point)
	if is_in_area2d == true:
		player_position = player.global_position
		#$"..".rotation += get_angular_speed(player_position.x-central_point.x)
		if player_position.x-central_point.x < 0 and $"..".rotation >= -0.522:  #0.522是30°
			$"..".rotation += get_angular_speed(player_position.x-central_point.x)
			$"../../Node2D".rotation += get_angular_speed(player_position.x-central_point.x)
			$"../../Node2D/CuttingBoard".rotation -= get_angular_speed(player_position.x-central_point.x)
			$"../../Node2D/Knife".rotation -= get_angular_speed(player_position.x-central_point.x)
		if player_position.x-central_point.x > 0 and $"..".rotation <= 0.522:
			$"..".rotation += get_angular_speed(player_position.x-central_point.x)
			$"../../Node2D".rotation += get_angular_speed(player_position.x-central_point.x)
			$"../../Node2D/CuttingBoard".rotation -= get_angular_speed(player_position.x-central_point.x)
			$"../../Node2D/Knife".rotation -= get_angular_speed(player_position.x-central_point.x)
