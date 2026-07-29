extends Control

@onready var hp_bar: TextureProgressBar = %HPBar

@onready var wasabi_icon: TextureRect = %WasabiIcon
# 芥末酱CD动画
@onready var wasabi_cd_bar: TextureProgressBar = %WasabiCDBar
@onready var wasabi_cd_player: AnimationPlayer = %WasabiCDPlayer

# 冰霜行者CD动画
@onready var ice_walk_cd_bar: TextureProgressBar = %IceWalkCDBar
@onready var ice_walk_cd_player: AnimationPlayer = $VBoxContainer/HBoxContainer2/IceWalkIcon/IceWalkCDPlayer
@onready var ice_walk_icon: TextureRect = %IceWalkIcon

var fishball:Player
var SkillsManager:Node2D

func _ready() -> void:
	wasabi_cd_bar.value = 100
	ice_walk_cd_bar.value = 100
	if owner is Player:
		fishball = owner
	if fishball:
		# 获取技能才有UI
		if fishball.get_icewalk:
			ice_walk_icon.visible = true
		if fishball.get_wasabi:
			wasabi_icon.visible = true
		hp_bar.value = fishball.HP
		# 修改动画时长
		change_animation(ice_walk_cd_player,"icewalktime",fishball.icewalk_time)
		change_animation(ice_walk_cd_player,"icewalkcd",fishball.icewalk_CD)
		change_animation(wasabi_cd_player,"default",fishball.wasabi_CD)
		if fishball.has_signal("take_damage_singal"):
			fishball.take_damage_singal.connect(_on_take_damage)
		if fishball.has_node("SkillsManager"):
			SkillsManager = fishball.get_node("SkillsManager")
			if SkillsManager.has_signal("use_skill_signal"):
				SkillsManager.use_skill_signal.connect(_on_use_skill)

func _on_take_damage(damage:float):
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
	
	
	
	
