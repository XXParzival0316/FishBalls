extends CharacterBody2D
class_name kill_enemy_platform

@export var lift_dis: float 
@export var lift_speed: float

@export var enemy_list : Array[Node2D] = []
var target_y


@export var is_active: bool = false       

func _ready():
	# 连接所有敌人的死亡信号
	for enemy in enemy_list:
		if enemy.has_signal("enemy_died"):
			enemy.enemy_died.connect(_on_enemy_died)

func _enter_tree() -> void:
	target_y = position.y - lift_dis
	
func _physics_process(delta: float) -> void:
	if enemy_list.is_empty() and is_active == false: 
		position.y = lerp(position.y, target_y, delta * lift_speed)
		
func _on_enemy_died(enemy: Node2D):
	if enemy in enemy_list:
		enemy_list.erase(enemy)
		print("敌人死亡，已从列表中移除")
