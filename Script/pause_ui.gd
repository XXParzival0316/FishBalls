extends CanvasLayer
@onready var pause_panel: Panel = %PausePanel

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_P and event.pressed:
			if not get_tree().paused:
				pause()
			else :
				unpause()

func pause():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().paused = true
	pause_panel.visible = true

func unpause():
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	get_tree().paused = false
	pause_panel.visible = false

func quit_game():
	get_tree().quit()
