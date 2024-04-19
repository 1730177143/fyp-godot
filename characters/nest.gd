extends Building

signal enemy_generation(num:int)
signal game_end
enum State{
	IDLE,
	DYING,
	HURT,
}

var pending_damage: Damage
var level : int = 0
var Enemy_attacker:PackedScene=preload("res://characters/enemies/attacker.tscn")

@export var generation_count: int = 0

@onready var generation_timer: Timer = $GenerationTimer
@onready var player_stats: Node = Game.player_stats
	
func _ready() -> void:
	pass


func tick_physics(state: State, delta: float) -> void:
	pass
	
func get_next_state(state: State) -> int:
	if stats.health <= 0:
		return StateMachine.KEEP_CURRENT if state == State.DYING else State.DYING
	
	if pending_damage and stats.health > 0:
		return State.HURT
		
	
	match state:
		State.IDLE:
			if stats.health <= 0:
				return State.DYING
		State.HURT:
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
			
		State.DYING:
			animation_player.play("dealth")
		
		State.HURT:
			stats.health -= pending_damage.amount
			pending_damage = null

func die() -> void:
	player_stats.material += 20
	generation_timer.set_paused(true)
	game_end.emit()

func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner


func _on_generation_timer_timeout() -> void:
	generation_count += 1
	enemy_generation.emit(generation_count)
	generation_timer.start()

	


func _on_enemy_generation(num: int) -> void:
	for i in range(num):
			var enemy_attacker_instance=Enemy_attacker.instantiate()
			enemy_attacker_instance.global_position=global_position
			get_parent().add_child(enemy_attacker_instance)


func _on_default_timer_timeout() -> void:
	enemy_generation.emit(3)
