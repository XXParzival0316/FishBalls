extends Sprite2D

var player:Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player and body.has_signal("interact") :
		player = body
		body.connect("interact",_on_interact)


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player and body.has_signal("interact"):
		player = null
		body.disconnect("interact",_on_interact)

func _on_interact() -> void:
	player.input_locked = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$CanvasLayer.visible = true


func _on_button_pressed() -> void:
	$CanvasLayer.visible = false
	player.input_locked = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
