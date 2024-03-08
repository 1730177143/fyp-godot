extends Node

const SAVE_PATH := "user://data.sav"
@onready var player_stats: Stats = $PlayerStats
@onready var default_player_stats := player_stats.to_dict()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
