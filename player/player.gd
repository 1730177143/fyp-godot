
extends CharacterBody2D
signal health_changed
signal shoot(Bullet, face_direction, muzzle_position_1, muzzle_position_2)
var Bullet: PackedScene = preload("res://characters/player_bullet.tscn")
@export var cooldown: float = 0.25
@export var gravity: int = 980
@export var horizonal_speed: int = 1000
@export var max_horizonal_speed: int = 150
@export var jump: int = -300
@export var jump_horizonal: int = 1000
@export var max_jump_horizontal: int = 100
@export var slow_down_speed: int = 2000
@export var health_amount:int=3


@onready var stats: Node = Game.player_stats

var rush_energy:float=4.0
var rush_rate:float=4.0
var cost_enery_per_frame:float=3
var interacting_with: Array[Interactable]
var interactable:Interactable
var muzzle_position
var can_shoot: bool = true
var pending_damage: Damage
enum State{
	idle,
	run,
	jump,
	idle_shoot,
	run_shoot,
	rush,
}
@export var current_state: State


func _ready():
	current_state=State.idle
	muzzle_position=$Muzzle.position


func _process(delta):
	pass


func _physics_process(delta):
	player_interact()
	player_falling(delta)
	player_idle(delta)
	player_run(delta)
	player_rush(delta)
	player_jump(delta)
	player_run_shoot(delta)
	player_idle_shoot(delta)
	
	move_and_slide()
	player_animation()


	#print("state:"+State.keys()[current_state])
	#print(stats.energy)


func player_falling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta


func player_idle(delta):
	if is_on_floor():
		current_state=State.idle


func player_run(delta) -> void:
	if !is_on_floor():
		return
	var direction: float = input_movement()
	if direction:
		velocity.x+= horizonal_speed * direction*delta
		velocity.x=clamp(velocity.x, -max_horizonal_speed, max_horizonal_speed)
	else:
		velocity.x = move_toward(velocity.x, 0, slow_down_speed*delta)
	if direction!=0:
		current_state=State.run
		$AnimatedSprite2D.flip_h=direction<0

func player_rush(delta):
	if Input.is_action_pressed("rush"):
		if  stats.energy < rush_energy:
			return 
		if !is_on_floor():
			return
		var direction: float = input_movement()
		stats.energy-= cost_enery_per_frame*delta
		if direction:
			velocity.x+= horizonal_speed*rush_rate * direction*delta
			velocity.x=clamp(velocity.x, -max_horizonal_speed*rush_rate, max_horizonal_speed*rush_rate)
		else:
			velocity.x = move_toward(velocity.x, 0, slow_down_speed*delta)
		if direction!=0:
			current_state=State.rush
			$AnimatedSprite2D.flip_h=direction<0


func player_jump(delta):
	if Input.is_action_just_pressed("jump"):
		velocity.y=jump
		current_state=State.jump
	if !is_on_floor() and current_state==State.jump:
		var direction: float = input_movement()
		velocity.x+=direction*jump_horizonal*delta
		velocity.x=clamp(velocity.x, -max_jump_horizontal, max_jump_horizontal)


func  player_run_shoot(delta):
	var direction: float = input_movement()
	if direction!=0&& Input.is_action_just_pressed("shoot"):
		shoot.emit(Bullet, $AnimatedSprite2D.flip_h, $Muzzle.global_position, $Muzzle2.global_position)
		current_state=State.run_shoot


func  player_idle_shoot(delta):
	var direction: float = input_movement()
	if direction==0 && Input.is_action_just_pressed("shoot"):
		shoot.emit(Bullet, $AnimatedSprite2D.flip_h, $Muzzle.global_position, $Muzzle2.global_position)
		current_state=State.idle_shoot

func register_interactable(v: Interactable) -> void:
	#if state_machine.current_state == State.DYING:
		#return
	if v in interacting_with:
		return
	interacting_with.append(v)


func unregister_interactable(v: Interactable) -> void:
	interacting_with.erase(v)
	
func player_interact():
	$InteracttionIcon.visible = not interacting_with.is_empty()
	if Input.is_action_just_pressed("interact") and interacting_with:
		interacting_with.back().interact()

func player_animation():
	if current_state==State.idle &&$AnimatedSprite2D.animation!="idle_shoot":
		$AnimatedSprite2D.play("idle")
	elif current_state == State.run &&$AnimatedSprite2D.animation!="run_shoot"&&$AnimatedSprite2D.animation!="rush":
		$AnimatedSprite2D.play("run")
	elif current_state==State.rush:
		$AnimatedSprite2D.play("rush")
	elif current_state==State.jump:
		$AnimatedSprite2D.play("jump")
	elif current_state==State.run_shoot:
		$AnimatedSprite2D.play("run_shoot")
	elif current_state==State.idle_shoot:
		$AnimatedSprite2D.play("idle_shoot")


func input_movement() -> float:
	var direction: float = Input.get_axis("move_left", "move_right")
	return direction


func _on_player_shoot(Bullet, face_direction, muzzle_position_1, muzzle_position_2):
	var bullet_instance = Bullet.instantiate()
	if face_direction:
		bullet_instance.position=muzzle_position_2
		bullet_instance.velocity=Vector2.LEFT
	else:
		bullet_instance.position=muzzle_position_1
		bullet_instance.velocity=Vector2.RIGHT
	get_parent().add_child(bullet_instance)




func _on_hurt_box_area_entered(area: Area2D) -> void:
	print("player hurt")
	health_changed.emit()
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = area.owner
	stats.health -= pending_damage.amount
	if area.get_parent().has_method("get_damage_amount"):
		health_amount-=area.get_parent().get_damage_amount()
		print("player health: "+ str(health_amount))
		if health_amount<=0:
			print("player died")
