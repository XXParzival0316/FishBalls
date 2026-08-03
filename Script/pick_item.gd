extends Sprite2D

@onready var area_2d: Area2D = $Area2D
func _ready() -> void:
	area_2d.body_entered.connect(_on_area_2d_body_entered)


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		var sm = body.get_node("SkillsManager")
		if name == "icewalk_pick":
			sm.get_icewalk()
		if name == "WasabiPick":
			sm.get_wasabi()
		queue_free()
