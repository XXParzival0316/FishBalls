extends RayCast2D

var is_icewalk:bool = false
var tilemapLayer:TileMapLayer = null
var ice_block:PackedScene = preload("res://Scenes/FishBall/Skills/IceWalk/ice_block.tscn")
var source_id:int
var ice_block_id:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_collision_mask_value(1,false)
	print(get_collision_mask())
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_icewalk:
		ice_walk()

func use(icewalk_time:float) -> void:
	is_icewalk = true
	print("冰霜行者:使用中 ","持续时间:",icewalk_time,"s")
	await get_tree().create_timer(icewalk_time).timeout
	is_icewalk = false

func ice_walk() -> void:
	if not tilemapLayer:
		# 获得水所在的TileMapLayer
		var collider = get_collider()
		if collider is TileMapLayer:
			tilemapLayer = collider
			# 对所在的TileMapLayer中的tileset进行设置,添加场景源
			if not source_id and not ice_block_id:
				var tile_set = tilemapLayer.tile_set
				var scene_source = TileSetScenesCollectionSource.new()
				# 对tileset添加一个新场景源
				source_id = tile_set.add_source(scene_source)
				# 对上面添加的场景源中添加冰砖块
				ice_block_id = scene_source.create_scene_tile(ice_block)
	else:
		# 确保碰到水和有之前的场景源才进行替换
		if source_id and ice_block_id and get_collider():
			# 复用第一次添加的场景源
			var target_vector = tilemapLayer.local_to_map(get_collision_point())
			var uesd_vector = tilemapLayer.get_cell_atlas_coords(target_vector)
			print(uesd_vector)
			
			tilemapLayer.set_cell(target_vector,source_id,Vector2i(0,0),ice_block_id)
