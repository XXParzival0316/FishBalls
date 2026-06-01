extends Node
# Author XXParzival

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func clear() -> void:
	# 灭霸响指
	var nodes =  get_children()
	for node in nodes:
		remove_child(node)
