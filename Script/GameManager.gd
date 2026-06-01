extends Node
# Author XXParzival


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_kitchen()
	load_Player(Vector2(244.0,198.0),"res://Scenes/Cameras/kitchen_camera.tscn")
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func load_kitchen() -> void:
	clear()
	var kitchen:PackedScene = load("res://Scenes/Maps/kitchen.tscn")
	var kitchen_instance = kitchen.instantiate()
	var cabinet_instance = kitchen_instance.get_node("Cabinet")
	var refrigerator_instance = kitchen_instance.get_node("Refrigerator")
	if refrigerator_instance.has_signal("request_switch"):
		refrigerator_instance.connect("request_switch",switch_scene)
	add_child(kitchen_instance)

func load_cabinet() -> void:
	clear()
	var cabinet:PackedScene = load("res://Scenes/Maps/test_cabinet.tscn")
	var cabinet_instance = cabinet.instantiate()
	add_child(cabinet_instance)

func load_refrigerator() -> void:
	clear()
	var refrigerator:PackedScene = load("res://Scenes/Maps/test_refrigerator.tscn")
	var refrigerator_instance = refrigerator.instantiate()
	add_child(refrigerator_instance)
	
func load_Player(Player_position:Vector2,CameraPath:NodePath) -> void:
	var fishball:PackedScene = load("res://Scenes/FishBall/fish_ball.tscn")
	var camera:PackedScene = load(CameraPath)
	var fb = fishball.instantiate()
	fb.add_child(camera.instantiate())
	fb.position = Player_position
	add_child(fb)
	

func clear() -> void:
	# 灭霸响指
	var nodes =  get_children()
	for node in nodes:
		remove_child(node)

func switch_scene(scene_name:String) -> void:
	match scene_name:
		"Refrigerator" :
			load_refrigerator()
		
