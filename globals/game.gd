extends Node

const SAVE_PATH := "user://data.sav"

# 场景的名称 => {
#   enemies_alive => [ 敌人的路径 ]
# }
var world_states := {}


@onready var player_stats: Stats = $PlayerStats
@onready var default_player_stats := player_stats.to_dict()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func change_scene(path: String, params := {}) -> void:
	pass
func save_game() -> void:
	var scene := get_tree().current_scene
	var scene_name := scene.scene_file_path.get_file().get_basename()
	world_states[scene_name] = scene.to_dict()
	
	var data := {
		world_states=world_states,
		stats=player_stats.to_dict(),
		scene=scene.scene_file_path,
		player={
			direction=scene.player.direction,
			position={
				x=scene.player.global_position.x,
				y=scene.player.global_position.y,
			},
		},
	}
	var json := JSON.stringify(data)
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		return
	file.store_string(json)


func load_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	
	var json := file.get_as_text()
	var data := JSON.parse_string(json) as Dictionary
	
	
	change_scene(data.scene, {
		direction=data.player.direction,
		position=Vector2(
			data.player.position.x,
			data.player.position.y
		),
		init=func ():
			world_states = data.world_states
			player_stats.from_dict(data.stats)
	})


func new_game() -> void:
	change_scene("res://worlds/forest.tscn", {
		duration=1,
		init=func ():
			world_states = {}
			player_stats.from_dict(default_player_stats)
	})


func back_to_title() -> void:
	change_scene("res://ui/title_screen.tscn", {
		duration=1,
	})


func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


