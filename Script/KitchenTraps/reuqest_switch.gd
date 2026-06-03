extends StaticBody2D

enum State {
	CLEAN,
	DIRTY
}

# 信号(请求切换)
signal request_switch(scene_name: String)
var player_target:CharacterBody2D = null
@export var state:State = State.DIRTY


func _ready() -> void:
	$Area2D.connect("body_entered",_on_area_2d_body_entered)
	$Area2D.connect("body_exited",_on_area_2d_body_exited)

func _physics_process(delta: float) -> void:
		if state == State.CLEAN:
			$Clean.visible = true
			$Dirty.visible = false
			
		if state == State.DIRTY:
			$Clean.visible = false
			$Dirty.visible = true

# 玩家进入识别区：开启交互
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_target = body
		player_target.connect("interact",_player_interacted)


# 玩家离开识别区：关闭交互
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_target:
		player_target.disconnect("interact",_player_interacted)
		player_target = null
		

func _player_interacted() -> void:
	print("请求跳转到:",name)
	request_switch.emit(name)
