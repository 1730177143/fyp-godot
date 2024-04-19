class_name Player
extends CharacterBody2D

signal shoot(Bullet, face_direction, muzzle_position_1, muzzle_position_2)


enum Direction {
	LEFT = -1,
	RIGHT = +1,
}

enum State {
	IDLE,
	RUNNING,
	RUSH,
	JUMP,
	FALL,
	SHOOT,
	RUNNING_SHOOT,
	HURT,
	DYING,
}

const GROUND_STATES := [
	State.IDLE, State.RUNNING,State.SHOOT,State.RUNNING_SHOOT,State.RUSH,
]
const RUN_SPEED := 160.0
const FLOOR_ACCELERATION := RUN_SPEED / 0.2
const AIR_ACCELERATION := RUN_SPEED / 0.1
# 是负数的原因是因为在2D空间中y轴向上为负
const JUMP_VELOCITY := -320.0
const WALL_JUMP_VELOCITY := Vector2(380, -280)
const KNOCKBACK_AMOUNT := 256.0
const COST_ENERGY_PER_FRAME := 3
const RUSH_RATE := 2.0
const RUSH_ENERGY := 4.0
const LANDING_HEIGHT := 100.0

@export var can_combo := false
@export var direction := Direction.RIGHT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		graphics.scale.x = direction
# 获取引擎给的重力加速度
var default_gravity := ProjectSettings.get("physics/2d/default_gravity") as float
var is_first_tick := false
var is_combo_requested := false
var pending_damage: Damage
var fall_from_y: float
var interacting_with: Array[Interactable]
var Bullet: PackedScene = preload("res://characters/player_bullet.tscn")

@onready var graphics: Node2D = $Graphics
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var sprite_2d: Sprite2D = $Graphics/Sprite2D
@onready var coyote_timer: Timer = $CoyoteTimer
@onready var jump_request_timer: Timer = $JumpRequestTimer
@onready var muzzle: Marker2D = $Muzzle
@onready var muzzle_2: Marker2D = $Muzzle2
@onready var shoot_timer: Timer = $ShootTimer
@onready var stats: Node = Game.player_stats
@onready var invincible_timer: Timer = $InvincibleTimer
@onready var game_over_screen: Control = $CanvasLayer/GameOverScreen
@onready var pause_screen: Control = $CanvasLayer/PauseScreen
@onready var interaction_icon: AnimatedSprite2D = $InteractionIcon
@onready var state_machine: StateMachine = $StateMachine

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUMP_VELOCITY / 2:
			velocity.y = JUMP_VELOCITY / 2
			
	if event.is_action_pressed("interact") and interacting_with:
		interacting_with.back().interact()
	
	if event.is_action_pressed("pause"):
		pause_screen.show_pause()



# 每个物理帧调用一次
func tick_physics(state: State, delta: float) -> void:
	interaction_icon.visible = not interacting_with.is_empty()
	
	if invincible_timer.time_left > 0:
		graphics.modulate.a = sin(Time.get_ticks_msec() / 20) * 0.5 + 0.5
	else:
		graphics.modulate.a = 1
		
	match state:
		State.IDLE:
			move(default_gravity, delta)
		
		State.RUNNING:
			move(default_gravity, delta)
		
		State.RUSH:
			rush(default_gravity, delta)
			stats.energy -= COST_ENERGY_PER_FRAME * delta
			
		State.JUMP:
			move(0.0 if is_first_tick else default_gravity, delta)
		
		State.FALL:
			move(default_gravity, delta)
		
		State.RUNNING_SHOOT:
			move(default_gravity, delta)
			shoot_bullet()
		
		State.SHOOT:
			stand(default_gravity, delta)
			shoot_bullet()
		
		State.HURT, State.DYING:
			stand(default_gravity, delta)
	
	is_first_tick = false


func move(gravity: float, delta: float) -> void:
	# 获取按键输入
	var movement := Input.get_axis("move_left", "move_right")
	# 修改速度向量
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, movement * RUN_SPEED, acceleration * delta)
	velocity.y += gravity * delta
	# 如果在移动，并且是向左移动，那么将角色水平翻转
	if not is_zero_approx(movement):
		direction = Direction.LEFT if movement < 0 else Direction.RIGHT
	
	move_and_slide()

func rush(gravity: float, delta: float) -> void:
	# 获取按键输入
	var movement := Input.get_axis("move_left", "move_right")
	# 修改速度向量
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, movement * RUN_SPEED * RUSH_RATE, acceleration * delta)
	velocity.y += gravity * delta
	# 如果在移动，并且是向左移动，那么将角色水平翻转
	if not is_zero_approx(movement):
		direction = Direction.LEFT if movement < 0 else Direction.RIGHT
	
	move_and_slide()

func stand(gravity: float, delta: float) -> void:
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
	velocity.y += gravity * delta
	
	move_and_slide()

func can_rush() -> bool:
	if Input.is_action_pressed("rush") and stats.energy >= RUSH_ENERGY:
		return true
	else :
		return false

func can_shoot()-> bool:
	var res:=Input.is_action_pressed("shoot") and shoot_timer.is_stopped()
	return res

func shoot_bullet() -> void:
	if can_shoot():
		shoot.emit(Bullet, direction==1, muzzle_2.global_position, muzzle.global_position)

func die() -> void:
	game_over_screen.show_game_over()

func register_interactable(v: Interactable) -> void:
	if state_machine.current_state == State.DYING:
		return
	if v in interacting_with:
		return
	interacting_with.append(v)

func unregister_interactable(v: Interactable) -> void:
	interacting_with.erase(v)

func get_next_state(state: State) -> int:
	if stats.health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	
	if pending_damage:
		return State.HURT
	
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump:
		return State.JUMP
	
	if state in GROUND_STATES and not is_on_floor():
		return State.FALL
	
	var movement := Input.get_axis("move_left", "move_right")
	var is_still := is_zero_approx(movement) and is_zero_approx(velocity.x)
	
	match state:
		State.IDLE:
			if can_shoot():
				return State.SHOOT
			if not is_still:
				if can_shoot():
					return State.RUNNING_SHOOT
				else :
					return State.RUNNING
		
		State.RUNNING:
			if can_shoot():
				return State.RUNNING_SHOOT
			if can_rush():
				return State.RUSH
			if is_still:
				if can_shoot():
					return State.SHOOT
				else :
					return State.IDLE
		
		State.JUMP:
			if velocity.y >= 0:
				return State.FALL
				
		State.FALL:	
			if is_on_floor():
				return State.IDLE
				
		State.RUNNING_SHOOT:
			if not animation_player.is_playing():
				return State.RUNNING
			if is_still:
				return State.IDLE
				
		State.SHOOT:
			if not animation_player.is_playing():
				return State.IDLE
				
		State.HURT:
			if not animation_player.is_playing():
				return State.IDLE
		State.RUSH:
			if not can_rush():
				return State.IDLE
		
	
	return StateMachine.KEEP_CURRENT

func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])

	
	if from not in GROUND_STATES and to in GROUND_STATES:
		coyote_timer.stop()
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		
		State.RUNNING:
			animation_player.play("running")
		
		State.JUMP:
			animation_player.play("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		
		State.FALL:
			animation_player.play("fall")
			if from in GROUND_STATES:
				coyote_timer.start()
			fall_from_y = global_position.y
		
		State.SHOOT:
			animation_player.play("shoot")
			SoundManager.play_sfx("Attack")
		
		State.RUNNING_SHOOT:
			animation_player.play("running_shoot")
		
		State.HURT:
			animation_player.play("hurt")
			
			#Input.start_joy_vibration(0, 0, 0.8, 0.8)
			#Game.shake_camera(4)
			
			stats.health -= pending_damage.amount
			
			var dir := pending_damage.source.global_position.direction_to(global_position)
			velocity = dir * KNOCKBACK_AMOUNT
			
			pending_damage = null
			invincible_timer.start()
		
		State.DYING:
			animation_player.play("die")
			invincible_timer.stop()
			interacting_with.clear()
			
		State.RUSH:
			animation_player.play("rush")
	
	is_first_tick = true


func _on_shoot(Bullet: PackedScene, face_direction: bool, muzzle_position_1: Vector2, muzzle_position_2: Vector2) -> void:
	var bullet_instance = Bullet.instantiate()
	if face_direction:
		bullet_instance.position=muzzle_position_2
		bullet_instance.velocity=Vector2.RIGHT
	else:
		bullet_instance.position=muzzle_position_1
		bullet_instance.velocity=Vector2.LEFT
	shoot_timer.start()
	get_parent().add_child(bullet_instance)


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	if invincible_timer.time_left > 0:
		return
	
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
