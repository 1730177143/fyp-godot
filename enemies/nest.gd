extends CharacterBody2D


signal enemy_created

@export var health_amount: int = 5
@export var Enemy_dealth_effect:PackedScene=preload("res://enemies/enemy_dealth_effect.tscn")
@export var damage_amount:int=1

var Enemy_attacker:PackedScene=preload("res://enemies/enemy_attacker.tscn")

@onready var stats: Node = Game.player_stats
func _ready() -> void:
	enemy_created.connect(create_enemy)
	
func _physics_process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	enemy_created.emit()

func create_enemy():
	var enemy_attacker_instance=Enemy_attacker.instantiate()
	enemy_attacker_instance.global_position=global_position
	get_parent().add_child(enemy_attacker_instance)

func enemy_dealth_effect():
	var enemy_dealth_effect_instance=Enemy_dealth_effect.instantiate()
	enemy_dealth_effect_instance.global_position=global_position
	stats.material+=10
	get_parent().add_child(enemy_dealth_effect_instance)
	queue_free()

func get_damage_amount() -> int:
	return damage_amount


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("nest hurt")
	if area.has_method("get_damage_amount"):
		health_amount-=area.get_damage_amount()
		print("enemy health: "+ str(health_amount))
		if health_amount<=0:
			enemy_dealth_effect()

