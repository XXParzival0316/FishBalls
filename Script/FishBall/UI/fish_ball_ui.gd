extends Control

@onready var hp_bar: TextureProgressBar = %HPBar

@onready var wasabi_icon: TextureRect = %WasabiIcon

# 芥末酱UICD动画
@onready var wasabi_cd_bar: TextureProgressBar = %WasabiCDBar
@onready var wasabi_cd_player: AnimationPlayer = %WasabiCDPlayer
@onready var wasabi_choose_border: TextureRect = %WasabiChooseBorder

# 冰霜行者UICD动画
@onready var ice_walk_cd_bar: TextureProgressBar = %IceWalkCDBar
@onready var ice_walk_cd_player: AnimationPlayer = $VBoxContainer/HBoxContainer2/IceWalkIcon/IceWalkCDPlayer
@onready var ice_walk_icon: TextureRect = %IceWalkIcon
@onready var ice_walk_choose_border: TextureRect = %IceWalkChooseBorder

var fishball:Player
var SkillsManager:Node2D


func _ready() -> void:
	wasabi_cd_bar.value = 100
	ice_walk_cd_bar.value = 100
	if owner is Player:
		fishball = owner
	if fishball:
		# 获取了技能才会显示UI
		ice_walk_icon.visible = fishball.get_icewalk
		wasabi_icon.visible = fishball.get_wasabi
		
		hp_bar.value = fishball.HP
		# 修改动画时长
		change_animation(ice_walk_cd_player,"icewalktime",fishball.icewalk_time)
		change_animation(ice_walk_cd_player,"icewalkcd",fishball.icewalk_CD)
		change_animation(wasabi_cd_player,"default",fishball.wasabi_CD)
		if fishball.has_signal("take_damage_signal"):
			fishball.take_damage_signal.connect(_on_take_damage)
		if fishball.has_node("SkillsManager"):
			SkillsManager = fishball.get_node("SkillsManager")
			if SkillsManager.has_signal("use_skill_signal"):
				SkillsManager.use_skill_signal.connect(_on_use_skill)
			if SkillsManager.has_signal("show_skill_select_signal"):
				SkillsManager.show_skill_select_signal.connect(_on_show_skill_select_)
				
func _physics_process(delta: float) -> void:
		if fishball:
		# 获取了技能才会显示UI
			ice_walk_icon.visible = fishball.get_icewalk
			wasabi_icon.visible = fishball.get_wasabi
func _on_take_damage(damage:float):
	print("接收到扣血信号来自:",fishball.name)
	hp_bar.value -= damage

func change_animation(animation_plaer:AnimationPlayer,anim_name:String,changetime:float):
	var anim = animation_plaer.get_animation(anim_name)
	anim.length = changetime
	anim.track_set_key_time(0,1,changetime)

	
func _on_use_skill(skill_name:String):
	if skill_name == "icewalk":
		ice_walk_cd_player.play("icewalktime")
		# 等上面time动画播放完
		ice_walk_cd_player.queue("icewalkcd")
	if skill_name == "wasabi":
		wasabi_cd_player.play("default")
	
func _on_show_skill_select_(skill_name:String):
	ice_walk_choose_border.visible = false
	wasabi_choose_border.visible = false

	if skill_name == "wasabi":
		wasabi_choose_border.visible = true
	if skill_name == "icewalk":
		ice_walk_choose_border.visible = true
	
