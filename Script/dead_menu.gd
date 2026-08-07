extends Control

@onready var restar: Button = $Restar
@onready var main_meu: Button = $MainMeu

var kitchen:PackedScene
func _ready() -> void:
	kitchen = load("res://Scenes/Maps/kitchen.tscn")
	
func _on_restar_pressed() -> void:
	get_tree().reload_current_scene()

func _on_main_meu_pressed() -> void:
	get_tree().change_scene_to_packed(kitchen)
