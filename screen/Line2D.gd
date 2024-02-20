extends Line2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var player = get_parent().find_child("Player")
	var position = player.position
	add_point(position)
	if (get_point_count() >= 60):
		remove_point(0)
	pass
