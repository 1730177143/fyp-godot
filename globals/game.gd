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


