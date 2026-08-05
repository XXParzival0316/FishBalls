extends RigidBody2D

# Author XXParzival

# 超时自动销毁
func _ready() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()

# 碰到玩家销毁
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is TileMapLayer:
		queue_free()	
