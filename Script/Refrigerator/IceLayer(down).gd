extends StaticBody2D

# ========== 冰层伤害参数 ==========
# 本层踩冰伤害参数
@export var ice_damage: float = 10.0
@export var damage_interval: float = 0.5
@export var damage_enable: bool = true

var damage_cool_down: bool = false

func _ready() -> void:
	# 绑定地面踩伤区域
	$HitArea.body_entered.connect(_on_player_step_in)
	$HitArea.body_exited.connect(_on_player_step_out)

# ========== 地面踩伤逻辑 ==========
func _on_player_step_in(body: Node2D) -> void:
	if not damage_enable or damage_cool_down:
		return
	# 玩家分组判定
	if body.is_in_group("Player"):
		_execute_damage(body)

func _on_player_step_out(body: Node2D) -> void:
	if body.is_in_group("Player"):
		damage_cool_down = false

func _execute_damage(player: Node2D) -> void:
	damage_cool_down = true
	player.take_damage(ice_damage)
	await get_tree().create_timer(damage_interval).timeout
	damage_cool_down = false

# ========== 辅助控制方法 ==========
# 启用/禁用伤害
func set_damage_enabled(enabled: bool) -> void:
	damage_enable = enabled

# 设置伤害值
func set_damage_amount(amount: float) -> void:
	ice_damage = amount

# 设置伤害间隔
func set_damage_interval(interval: float) -> void:
	damage_interval = interval
