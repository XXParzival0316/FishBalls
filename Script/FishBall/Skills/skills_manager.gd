extends Node2D

@onready var fb: CharacterBody2D = $".."

# 获得的技能
var skills_arr:Array = Array()
# 当前选中技能
var active_skill:String

var can_use_icewalk:bool = true
var icewalk:PackedScene = preload("res://Scenes/FishBall/Skills/IceWalk/icewalk.tscn")
var icewalk_inst:RayCast2D

var can_use_wasabi:bool = true
var wasabi_spawner:PackedScene = preload("res://Scenes/FishBall/Skills/Wasabi/WasabiSpawner.tscn")
var wasabi_spawner_inst

# 各技能初始化
func _ready() -> void:
	if fb.get_wasabi:
		print("获得芥末酱技能")
		skills_arr.append("wasabi")
		wasabi_spawner_inst = wasabi_spawner.instantiate()
		add_child(wasabi_spawner_inst)
	if fb.get_icewalk:
		icewalk_inst = icewalk.instantiate()
		add_child(icewalk_inst)
		print("获得冰霜行者技能")
		skills_arr.append("icewalk")
	# 选中最后一个获得的技能
	if skills_arr:
		active_skill = skills_arr[skills_arr.size()-1]

func _input(event: InputEvent) -> void:
	# 技能使用
	if active_skill:
		if event.is_action_pressed("ui_up"):
			use_skill()
	# 技能选择
	if skills_arr:
		if event.is_action_pressed("ui_left"):
			switch_skills("last")
		if event.is_action_pressed("ui_right"):
			switch_skills("next")

func switch_skills(direct:String) -> void:
	var skill_index = skills_arr.find(active_skill)
	match direct:
		"last":
			if skill_index:
				print("切换上一个技能")
				active_skill = skills_arr[skill_index-1]
			else:
				print("已经是最开始的技能了")
		"next":
			if skill_index != skills_arr.size()-1:
				active_skill = skills_arr[skill_index+1]
				print("切换下一个技能")
			else:
				print("已经是最后的技能了")

func use_skill() -> void:
	match active_skill:
		"icewalk":
			use_icewalk()
		"wasabi":
			use_wasabi()

## 创建计时器
func create_timer(wait_time:float,func_name:Callable,timer_name ="timer"):
	var timer:Timer = Timer.new()
	timer.name = timer_name
	timer.set_wait_time(wait_time)
	timer.timeout.connect(func_name)
	add_child(timer)
	timer.start()

# 统一管理技能CD&持续时间
func use_icewalk() -> void:
	if can_use_icewalk:
		can_use_icewalk = false
		## 等冰行持续时间结束,才开始创建CD计时器
		await icewalk_inst.use(fb.icewalk_time,fb.iceblock_time)
		if not has_node("icewalk_timer"):
			print("冰霜行者:冷却--",fb.icewalk_CD,"s")
			create_timer(fb.icewalk_CD,_on_icewalk_CD_timeout,"icewalk_timer")


func _on_icewalk_CD_timeout() -> void:
		can_use_icewalk = true
		print("冰霜行者:就绪")
		$icewalk_timer.queue_free()
		
func use_wasabi() -> void:
	if can_use_wasabi:
		var is_flip = fb.get_node("AnimatedSprite2D").flip_h
		can_use_wasabi = false
		wasabi_spawner_inst.use(is_flip,fb.position,fb.wasabi_damage)
		if not has_node("wasabi_timer"):
			print("芥末:冷却--",fb.wasabi_CD,"s")
			create_timer(fb.wasabi_CD,_on_wasabi_CD_timeout,"wasabi_timer")

func _on_wasabi_CD_timeout() -> void:
		can_use_wasabi = true
		print("芥末:就绪")
		$wasabi_timer.queue_free()
