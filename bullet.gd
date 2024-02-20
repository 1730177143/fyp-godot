extends Area2D
@export var speed =1000
var velocity =Vector2.RIGHT

func _physics_process(delta):
	position += velocity *speed* delta

func _on_timer_timeout():
	queue_free()
