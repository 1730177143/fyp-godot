extends Building

enum State{
	LV0,
	LV1,
	LV2,
	HURT,
}

var pending_damage: Damage
var can_building := true
var can_upgrade := false
var upgrade := false
var can_repair := false


var generation_count: int = 0
@export var level := State.LV0

@onready var player_stats: Node = Game.player_stats
@onready var hurt_timer: Timer = $HurtTimer
	
func _ready() -> void:
	pass


func tick_physics(state: State, delta: float) -> void:
	pass
	
func get_next_state(state: State) -> int:
	if stats.health <= 0:
		return StateMachine.KEEP_CURRENT if state == State.LV0 else State.LV0
	
	if pending_damage:
		return State.HURT
		
	if stats.health <= 0:
		return State.LV0
	
	if state_machine.current_state != level:
		return level
	
	match state:
		State.LV0:
			if not can_building:
				level = State.LV1
				return level
				
		State.LV1:
			if upgrade:
				upgrade = false
				level = State.LV2
				return level
				
		State.HURT:
			if not animation_player.is_playing():
				return level
	
	return StateMachine.KEEP_CURRENT


func transition_state(from: State, to: State) -> void:
	print("[%s] %s => %s" % [
		Engine.get_physics_frames(),
		State.keys()[from] if from != -1 else "<START>",
		State.keys()[to],
	])
	
	match to:
		State.LV0:
			animation_player.play("lv0")
			
		State.LV1:
			animation_player.play("lv1")
		
		State.LV2:
			animation_player.play("lv2")
		
		State.HURT:
			stats.health -= pending_damage.amount
			pending_damage = null


func _on_hurtbox_hurt(hitbox: Hitbox) -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	pending_damage.source = hitbox.owner
	hurt_timer.start()

func upgrade_level() -> void:
	if can_upgrade:
		if level == State.LV0:
			level = State.LV1
		else :
			level = State.LV2
			can_upgrade = false
	

func _on_interactable_interacted() -> void:
	if player_stats.material <5:
		return
	player_stats.material -= 5
	if can_building:
		can_building = false
	elif  stats.health < stats.max_health:
		stats.health = stats.max_health
	else :
		upgrade = true


func _on_hurt_timer_timeout() -> void:
	pending_damage = Damage.new()
	pending_damage.amount = 1
	hurt_timer.start()


func _on_hurtbox_exit() -> void:
	hurt_timer.stop()
