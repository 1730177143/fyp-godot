extends CharacterBody2D


@export var speed:int = 300

#const JUMP_VELOCITY = -400.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
enum State{
	idle,
	walk
}
@export var current_state :State
@export var direction:Vector2=Vector2.LEFT
func _ready():
	current_state=State.idle




func _physics_process(delta):
	enemy_falling(delta)
	enemy_idle(delta)
	enemy_walk(delta)


	move_and_slide()
func enemy_falling(delta):
	if !is_on_floor():
		velocity.y += gravity * delta
func enemy_idle(delta):
	velocity.x=move_toward(velocity.x,0,speed*delta)
	current_state=State.idle
		
func enemy_walk(delta):
	velocity.x= speed * direction.x*delta
	current_state=State.walk
	$AnimatedSprite2D.flip_h=false if direction.x>0 else true
func enemy_animation():
	if current_state==State.idle:
		$AnimatedSprite2D.play("idle")
	elif current_state == State.walk:
		$AnimatedSprite2D.play("walk")
