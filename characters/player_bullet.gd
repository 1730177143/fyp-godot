extends Hitbox
@export var Bullet_impact_effect: PackedScene = preload("res://characters/bullet_impact_effect.tscn")
@export var velocity: Vector2 = Vector2.RIGHT
@export var speed: int = 500
@export var damage_amount: int = 1


func _physics_process(delta: float) -> void:
	position +=speed* velocity * delta


func bullet_impact_effect():
	var bullet_impact_effect_instance = Bullet_impact_effect.instantiate()
	bullet_impact_effect_instance.global_position=global_position
	get_parent().add_child(bullet_impact_effect_instance)
	queue_free()


func get_damage_amount() -> int:
	return damage_amount


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_entered(hurtbox: Hurtbox) -> void:
	print("[Hit] %s => %s" % [name, hurtbox.owner.name])
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)
	bullet_impact_effect()
