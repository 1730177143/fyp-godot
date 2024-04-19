extends Control
var lines := [
	"You are Victority !",
	"You finished the first level.",
]

var current_line := -1
var tween: Tween

@onready var label: Label = $Label
@onready var player_stats: Node = Game.player_stats

func _ready() -> void:
	var s := "You killed %s enemies." 
	s = s % player_stats.kill_enemies_amount
	lines.append(s)
	show_line(0)
	SoundManager.play_bgm(preload("res://pixel_assets/bgm/29 15 game over LOOP.mp3"))


func _input(event: InputEvent) -> void:
	if tween.is_running():
		return
	
	if (
		event is InputEventKey or
		event is InputEventMouseButton or
		event is InputEventJoypadButton
	):
		if event.is_pressed() and not event.is_echo():
			if current_line + 1 < lines.size():
				show_line(current_line + 1)
			else:
				Game.back_to_title()


func show_line(line: int) -> void:
	current_line = line
	
	tween = create_tween()
	tween.set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	if line > 0:
		tween.tween_property(label, "modulate:a", 0, 1)
	else:
		label.modulate.a = 0
	
	tween.tween_callback(label.set_text.bind(lines[line]))
	tween.tween_property(label, "modulate:a", 1, 1)
