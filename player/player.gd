extends CharacterBody2D

signal shoot(bullet, direction, location)
var Bullet = preload("res://bullet.tscn")

@export var cooldown:float = 0.25
@export var gravity:int=980
@export var speed:int=300
var can_shoot = true
enum State{
	idle,
	run
}
@export var current_state:State


#
#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#shoot.emit(Bullet, rotation, position)

func _ready():
	current_state=State.idle


func _process(delta):
	pass


func _physics_process(delta):
	player_falling(delta)
	player_idle()
	player_run()
	player_animation()
	move_and_slide()
	print("state:"+State.keys()[current_state])
func player_falling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
func player_idle():
	if is_on_floor():
		current_state=State.idle
		
func player_run():
	var direction=input_movement()
	if direction:
		velocity.x= speed * direction
	else:
		velocity.x = move_toward(velocity.x,0,speed)
	if direction!=0:
		current_state=State.run
		$AnimatedSprite2D.flip_h=false if direction>0 else true
		
func player_animation():
	if current_state==State.idle:
		$AnimatedSprite2D.play("idle")
	elif current_state == State.run:
		$AnimatedSprite2D.play("run")
func input_movement():
	var direction=Input.get_axis("move_left","move_right")
	return direction
func _on_player_shoot(Bullet, direction, location):
	print("creat bullet")
	var spawned_bullet = Bullet.instantiate()
	get_parent().add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
