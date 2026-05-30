# Author Baishu
extends Enemy

func _enter_tree() -> void:
	super._enter_tree()
	normal_speed = 100

func _ready() -> void:
	super._ready()
