extends Area2D

var velocity : Vector2
@export var speed = 500

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position += speed * velocity * delta

func _on_timer_timeout():
	queue_free()
