extends Marker2D
# Author XXParzival

@onready var timer: Timer = $Timer

@export
## 水滴间隔时间
var time:float = 1
var drip_scene:PackedScene = preload("res://Scenes/Refrigerator/Drip/Drip.tscn")

func _ready() -> void:
	timer.wait_time = time
	timer.start()

func drip_spawner():
	var drip = drip_scene.instantiate()
	add_child(drip)
	
func _on_timer_timeout() -> void:
	drip_spawner()
