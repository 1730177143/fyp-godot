extends Area2D
@export var Bullet_impact_effect: PackedScene = preload("res://player/bullet_impact_effect.tscn")
@export var velocity: Vector2 = Vector2.RIGHT
@export var speed: int = 500
@export var damage_amout: int = 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	position +=speed* velocity * delta


func bullet_impact_effect():
	var bullet_impact_effect_instance = Bullet_impact_effect.instantiate()
	bullet_impact_effect_instance.global_position=global_position
	get_parent().add_child(bullet_impact_effect_instance)
	queue_free()


func get_damage_amount() -> int:
	return damage_amout


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	print("area_entered")
	bullet_impact_effect()


func _on_body_entered(body: Node2D) -> void:
	print("body_entered")
	bullet_impact_effect()
