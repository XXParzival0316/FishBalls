extends StaticBody2D

@onready var area_2d: Area2D = $Area2D

@export var base_force:float = 150.0
@export var max_force:float = 600.0
@export var force_add_speed:float = 120.0

var now_force:float = 0.0
var is_steam_active = false
var player_target = null

func _ready() -> void:
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	# 确认是玩家
	if body.is_in_group("Player"):
		is_steam_active = true
		player_target = body
		
		
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_target:
		is_steam_active = false
		player_target = body
		now_force = base_force # 进入重置初始化重力

	
func _physics_process(delta: float) -> void:
	if is_steam_active and player_target:
		now_force = min(now_force + force_add_speed * delta,max_force)
		player_target.velocity.y -= now_force
	else:
		now_force = 0.0
