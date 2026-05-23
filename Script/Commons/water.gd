extends Area2D
# Author Baishu

@export var buoyancy : float = 0.5 #浮力
@export var slow : float = 0.5 #减速系数
@export var gravity_in_water : float = 0.5 #在水中的重力

func _ready() -> void:
	body_entered.connect(_fall_into_water)
	body_exited.connect(_exited_the_water)
	
func _fall_into_water(player:Node2D):
	if player.has_method("fall_in_water"): #检测进入的物体身上有没有“fall_in_water"这个函数
		player.get
		#target_in_area.append(body)
		
		print("fall in water")
func _exited_the_water(body:Node2D):
	pass
