extends Control

var kitchen:PackedScene = preload("res://Scenes/Maps/kitchen.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(kitchen)

func _on_exit_pressed() -> void:
	get_tree().quit()
