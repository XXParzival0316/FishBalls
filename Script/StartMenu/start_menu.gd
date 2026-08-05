extends Control

var kitchen_inst

var kitchen:PackedScene
func _ready() -> void:
	kitchen = preload("res://Scenes/Maps/kitchen.tscn")
	kitchen_inst = kitchen.instantiate()
	kitchen_inst.first_play_game = true

func _on_start_pressed() -> void:
	get_tree().change_scene_to_node(kitchen_inst)


func _on_exit_pressed() -> void:
	get_tree().quit()
