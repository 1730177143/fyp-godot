extends CharacterBody2D

signal shoot(bullet, direction, location)

var Bullet = preload("res://bullet.tscn")
@export var cooldown = 0.25
@export var bullet_scene : PackedScene
var can_shoot = true
# How fast the player will move (pixels/sec).
@export var speed = 800
# Size of the game window.
var screen_size
#func _input(event):
	#if event is InputEventMouseButton:
		#if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			#shoot.emit(Bullet, rotation, position)

func _ready():
	screen_size = get_viewport_rect().size
	self.connect("shoot",Callable(self,"_on_player_shoot"))
func _process(delta):
	#look_at(get_global_mouse_position())
	pass
func _physics_process(delta):
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if velocity.length() <= 0:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		var dir = get_global_mouse_position() - position
		shoot.emit(position, dir)
	
	velocity = velocity.normalized() * speed
	# false这个选项参数看意思是把无限惯性关了，这个关了之后就不会向碰撞的刚体施加作用力，需要你自己去写
	var info: KinematicCollision2D = move_and_collide(velocity * delta)
	if info != null:
		print(info.get_collider())	
func _on_player_shoot(Bullet, direction, location):
	print("creat bullet")
	var spawned_bullet = Bullet.instantiate()
	add_child(spawned_bullet)
	spawned_bullet.rotation = direction
	spawned_bullet.position = location
	spawned_bullet.velocity = spawned_bullet.velocity.rotated(direction)
