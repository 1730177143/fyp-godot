extends Node2D


# Called when the node enters the scene tree for the first time.

func _ready():
	var button = get_node("OptionsButton")
#	button.connect("pressed", self, "_on_Button_pressed")

func _on_Button_pressed():
	get_tree().change_scene("res://OptionsScreen.tscn")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
