extends Enemy

enum State{
	RUN,
	IDLE,
	ATTACK,
	HURT,
	DYING,
}

const KNOCKBACK_AMOUNT := 512.0

var pending_damage: Damage

@onready var player_checker: RayCast2D = $Graphics/PlayerChecker
@onready var attack_checker: RayCast2D = $Graphics/AttackChecker
@onready var calm_down_timer: Timer = $CalmDownTimer


func can_see_player() -> bool:
	if not player_checker.is_colliding():
		return false
	return player_checker.get_collider() is Player
	
func tick_physics(state: State, delta: float) -> void:
	match state:
		State.IDLE,State.DYING,State.HURT:
			move(0.0, delta)
		
		State.ATTACK:
			if attack_checker.is_colliding():
				calm_down_timer.start()
		State.RUN:
			move(max_speed, delta)
	
func get_next_state(state: State) -> int:
	if stats.health == 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	
	if pending_damage:
		return State.HURT
	
	match state:
		State.IDLE:
			if can_see_player() and calm_down_timer.is_stopped():
				return State.RUN
			if state_machine.state_time > 2:
				direction*=-1
				state_machine.state_time=0
				player_checker.force_raycast_update()

		
		State.RUN:
			if attack_checker.is_colliding():
				return State.ATTACK
			if not can_see_player():
				return State.IDLE
		
		State.ATTACK:
			if not attack_checker.is_colliding() :
				return State.IDLE
		
		State.HURT:
			if not animation_player.is_playing():
				return State.IDLE
	
	return StateMachine.KEEP_CURRENT


func transition_state(from: State, to: State) -> void:
	#print("[%s] %s => %s" % [
		#Engine.get_physics_frames(),
		#State.keys()[from] if from != -1 else "<START>",
		#State.keys()[to],
	#])
	
	match to:
		State.IDLE:
			animation_player.play("idle")

		
		State.ATTACK:
			animation_player.play("attack")
		
		State.RUN:
			animation_player.play("run")
		
		State.HURT:
			animation_player.play("hit")
			
			stats.health -= pending_damage.amount
			
			#var dir := pending_damage.source.global_position.direction_to(global_position)
			#velocity = dir * KNOCKBACK_AMOUNT
			#
			#if dir.x > 0:
				#direction = Direction.LEFT
			#else:
				#direction = Direction.RIGHT
			
			pending_damage = null
		
		State.DYING:
			animation_player.play("die")


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
