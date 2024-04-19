class_name Building
extends CharacterBody2D

enum Direction {
	LEFT = -1,
	RIGHT = +1,
}

signal died

@export var direction := Direction.LEFT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = -direction


var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: Node = $StateMachine
@onready var stats: Node = $Stats




func die() -> void:
	
	died.emit()
