extends Control

# Called when the node enters the scene tree for the first time.

func _ready():
	$NewButton.pressed.connect(_new_pressed)
	$OptionsButton.pressed.connect(_options_pressed)
	$QuitButton.pressed.connect(_quit)


func _options_pressed():
	get_tree().change_scene_to_file("res://screen/Options.tscn")


func _new_pressed():
	get_tree().change_scene_to_file("res://map/test_map.tscn")


func _quit():
	get_tree().quit(0)


func _process(delta):
	pass

