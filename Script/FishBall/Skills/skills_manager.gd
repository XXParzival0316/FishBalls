extends Node2D
# Author XXParzival

@onready var fb: Player = $".."

signal	use_skill_signal(skill_name:String)
signal show_skill_select_signal(skill_name:String)

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
		# 空闲时发射信号，直接发射UI节点还没初始化完毕
		call_deferred("_emit_show_skill_select_signal")
	

func _input(event: InputEvent) -> void:
	if fb.input_locked:
		return
	# 技能使用
	if active_skill:
		if event.is_action_pressed("Use_Skill"):
			use_skill()
	# 技能选择
	if skills_arr:
		if event.is_action_pressed("Last_Skill"):
			switch_skills("last")
		if event.is_action_pressed("Next_Skill"):
			switch_skills("next")

func switch_skills(direct:String) -> void:
	var skill_index = skills_arr.find(active_skill)
	match direct:
		"last":
			if skill_index:
				active_skill = skills_arr[skill_index-1]
				show_skill_select_signal.emit(active_skill)
		"next":
			if skill_index != skills_arr.size()-1:
				active_skill = skills_arr[skill_index+1]
				show_skill_select_signal.emit(active_skill)

func _emit_show_skill_select_signal():
	show_skill_select_signal.emit(active_skill)
	
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
		use_skill_signal.emit("icewalk")
		can_use_icewalk = false
		## 等冰行持续时间结束,才开始创建CD计时器
		await icewalk_inst.use(fb.icewalk_time,fb.iceblock_time,fb.using_icewalk)
		if not has_node("icewalk_timer"):
			print("冰霜行者:冷却--",fb.icewalk_CD,"s")
			create_timer(fb.icewalk_CD,_on_icewalk_CD_timeout,"icewalk_timer")


func _on_icewalk_CD_timeout() -> void:
		can_use_icewalk = true
		print("冰霜行者:就绪")
		$icewalk_timer.queue_free()
		
func use_wasabi() -> void:
	if can_use_wasabi:
		use_skill_signal.emit("wasabi")
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
