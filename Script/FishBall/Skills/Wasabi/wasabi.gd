extends RigidBody2D
# Author XXParzival

var damage:float = 10.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 1s过后加上碰撞层1，防止撞到鱼蛋直接消失
	await  get_tree().create_timer(0.1).timeout
	set_collision_mask_value(1,true)
	# 超过5s自动摧毁
	await  get_tree().create_timer(5).timeout
	queue_free()
	pass # Replace with function body.

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Enemy"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
	if not body.is_in_group("Player"):
		queue_free()
