extends RayCast2D

var is_icewalk:bool = false
var tilemapLayer:TileMapLayer = null
var ice_block:PackedScene = preload("res://Scenes/FishBall/Skills/IceWalk/ice_block.tscn")
var source_id:int
var ice_block_id:int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_icewalk:
		ice_walk()

func use() -> void:
	is_icewalk = true

func ice_walk() -> void:
	if !tilemapLayer:
		# 获得水所在的TileMapLayer
		var collider = get_collider()
		if collider is TileMapLayer:
			tilemapLayer = collider
			# 对所在的TileMapLayer中的tileset进行设置,之前要是添加过了就复用之前的场景源
			if not source_id and not ice_block_id:
				var tile_set = tilemapLayer.tile_set
				var scene_source = TileSetScenesCollectionSource.new()
				# 对tileset添加一个新场景源
				source_id = tile_set.add_source(scene_source)
				# 对上面添加的场景源中添加冰砖块
				ice_block_id = scene_source.create_scene_tile(ice_block)
	else:	
		if source_id and ice_block_id:
			var target_vector = tilemapLayer.local_to_map(get_collision_point())
			tilemapLayer.set_cell(target_vector,source_id,Vector2i(0,0),ice_block_id)
