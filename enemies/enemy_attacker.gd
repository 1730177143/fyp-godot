extends CharacterBody2D

enum State{
	idle,
	walk
}
@export var speed: int = 1500
@export var current_state: State
@export var direction: Vector2 = Vector2.LEFT
@export var patrol_points: Node
@export var wait_time: int = 1
@export var health_amount: int = 3
@export var Enemy_dealth_effect:PackedScene=preload("res://enemies/enemy_dealth_effect.tscn")
@export var damage_amount:int=1

@onready var stats: Node = Game.player_stats


var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var number_of_points: int
var points_position: Array[Vector2]
var current_point: Vector2
var current_point_position: int
var can_walk: bool



func _ready():
	if patrol_points!=null:
		number_of_points=patrol_points.get_children().size()
		for point in patrol_points.get_children():
			points_position.append(point.global_position)
		current_point=points_position[current_point_position]
	else:
		print("No Patrolpoints!")
	current_state=State.idle
	$Timer.wait_time=3


func _physics_process(delta):
	enemy_falling(delta)
	enemy_idle(delta)
	enemy_walk(delta)

	move_and_slide()
	enemy_animation()


func enemy_falling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta


func enemy_idle(delta):
	if !can_walk:
		velocity.x=move_toward(velocity.x, 0, speed*delta)

	current_state=State.idle


func enemy_walk(delta) -> void:
	if !can_walk:
		return
	if abs(position.x-current_point.x)>0.5:
		velocity.x= speed * direction.x*delta
		current_state=State.walk
	else:
		current_point_position+=1
		if current_point_position>=number_of_points:
			current_point_position=0
		current_point=points_position[current_point_position]

		if current_point.x>position.x:
			direction=Vector2.RIGHT
		else:
			direction = Vector2.LEFT
		can_walk=false
		$Timer.start()
	$AnimatedSprite2D.flip_h=direction.x>0


func enemy_animation():
	if current_state==State.idle &&!can_walk:
		$AnimatedSprite2D.play("idle")
	elif current_state == State.walk && can_walk:
		$AnimatedSprite2D.play("walk")

func enemy_dealth_effect():
	var enemy_dealth_effect_instance=Enemy_dealth_effect.instantiate()
	enemy_dealth_effect_instance.global_position=global_position
	stats.material+=3
	get_parent().add_child(enemy_dealth_effect_instance)
	queue_free()

func get_damage_amount() -> int:
	return damage_amount


func _on_timer_timeout() -> void:
	can_walk=true


func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("enemy hurt")
	if area.has_method("get_damage_amount"):
		health_amount-=area.get_damage_amount()
		print("enemy health: "+ str(health_amount))
		if health_amount<=0:
			enemy_dealth_effect()


func _on_hurt_box_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
