class_name Interactable
extends Area2D

signal interacted
@export var Wall:PackedScene=preload("res://buildings/wall.tscn")

@onready var stats: Node = Game.player_stats

func _init() -> void:
	collision_layer = 0
	collision_mask = 0
	set_collision_mask_value(2, true)
	
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func interact() -> void:
	print("[Interact] %s" % name)
	interacted.emit()
	stats.material-=5
	var wall_instance=Wall.instantiate()
	wall_instance.global_position=global_position
	get_parent().add_child(wall_instance)
	


func _on_body_entered(player: Player) -> void:
	player.register_interactable(self)


func _on_body_exited(player: Player) -> void:
	player.unregister_interactable(self)
