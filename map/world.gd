class_name World
extends Node2D

@export var bgm: AudioStream

@onready var tile_map: TileMap = $TileMap
@onready var camera_2d: Camera2D = $Player/Camera2D
@onready var player: Player = $Player


func _ready() -> void:
	# 获取瓦片地图的范围
	var used := tile_map.get_used_rect().grow(-1)
	# 获取单个图块的尺寸
	var tile_size:=tile_map.tile_set.tile_size
	# 为相机的上下左右添加限制
	camera_2d.limit_top= used.position.y * tile_size.y
	camera_2d.limit_right= used.end.x * tile_size.x
	camera_2d.limit_bottom= used.end.y * tile_size.y
	camera_2d.limit_left= used.position.x * tile_size.x
	# 将相机的位置立即设置为其当前平滑的目标位置。
	camera_2d.reset_smoothing()
	if bgm:
		SoundManager.play_bgm(bgm)


func update_player(pos: Vector2, direction: Player.Direction) -> void:
	player.global_position = pos
	player.fall_from_y = pos.y
	player.direction = direction
	camera_2d.reset_smoothing()
	camera_2d.force_update_scroll()  # 4.2 开始


func to_dict() -> Dictionary:
	var enemies_alive := save_enemy_to_dict("enemies")
	var buildings_exist := save_building_to_dict("buildings")
	var player_bullets := save_bullet_to_dict("bullets")
	return {
		enemies_alive=enemies_alive,
		buildings_exist=buildings_exist,
		player_bullets=player_bullets,
	}

func save_bullet_to_dict(s: String) -> Array:
	var res := []
	for node in get_tree().get_nodes_in_group(s):
		var path := get_path_to(node) as String
		var temp := {
			"path" : path,
			"filename" : node.get_scene_file_path(),
			"parent" : node.get_parent().get_path(),
			"pos_x" : node.position.x,
			"pos_y" : node.position.y,
			"vel_x" : node.velocity.x,
			"vel_y" : node.velocity.y
		}
		res.append(temp)
	return res

func save_enemy_to_dict(s: String) -> Array:
	var res := []
	for node in get_tree().get_nodes_in_group(s):
		var path := get_path_to(node) as String
		var temp := {
			"path" : path,
			"filename" : node.get_scene_file_path(),
			"parent" : node.get_parent().get_path(),
			"pos_x" : node.position.x,
			"pos_y" : node.position.y,
			#"health" :node.get_child(-1).health,
		}
		res.append(temp)
	return res

func save_building_to_dict(s: String) -> Array:
	var res := []
	for node in get_tree().get_nodes_in_group(s):
		var path := get_path_to(node) as String
		var temp := {
			"path" : path,
			"filename" : node.get_scene_file_path(),
			"parent" : node.get_parent().get_path(),
			"pos_x" : node.position.x,
			"pos_y" : node.position.y,
			"level" : node.level,
			"generation_count" : node.generation_count
			#"health" :node.get_child(-2).health,
		}
		res.append(temp)
	return res

func from_dict(dict: Dictionary) -> void:
	#for node in get_tree().get_nodes_in_group("enemies"):
		#var path := get_path_to(node) as String
		#if path not in dict.enemies_alive:
			#node.queue_free()
	for node_data in dict.enemies_alive:
		load_data(node_data)
	for node_data in dict.player_bullets:
		load_data(node_data)
	for node in get_tree().get_nodes_in_group("buildings"):
		var path := get_path_to(node) as String
		for node_data in dict.buildings_exist:
			if path == node_data.path:
				node.set("level",node_data.level)
	
func load_data(node_data: Dictionary) -> void:
	# Firstly, we need to create the object and add it to the tree and set its position.
	var new_object = load(node_data["filename"]).instantiate()
	get_node(node_data["parent"]).add_child(new_object)
	new_object.position = Vector2(node_data["pos_x"], node_data["pos_y"])
	if node_data.has("vel_x"):
		new_object.velocity = Vector2(node_data["vel_x"], node_data["vel_y"])

	# Now we set the remaining variables.
	for i in node_data.keys():
		if i == "filename" or i == "parent" or i == "pos_x" or i == "pos_y":
			continue
		new_object.set(i, node_data[i])




func _on_game_end() -> void:
	await get_tree().create_timer(1).timeout
	Game.change_scene("res://ui/game_end_screen.tscn", {
		duration=1,
	})
