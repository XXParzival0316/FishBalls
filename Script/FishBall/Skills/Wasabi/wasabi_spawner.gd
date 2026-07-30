extends Node2D
# Author XXParzival

var wasabi:PackedScene = preload("res://Scenes/FishBall/Skills/Wasabi/wasabi.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func use(is_filp:bool,fb_position:Vector2,wasabi_damage:float) -> void:
	var wasabi_inst = wasabi.instantiate()
	if not is_filp:
		wasabi_inst.linear_velocity.x = 500
	wasabi_inst.damage = wasabi_damage
	add_child(wasabi_inst)
