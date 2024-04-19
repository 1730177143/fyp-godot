class_name Hitbox
extends Area2D

signal hit(hurtbox)


func _init() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func _on_area_entered(hurtbox: Hurtbox) -> void:
	print("[Hit] %s => %s" % [owner.name, hurtbox.owner.name])
	hit.emit(hurtbox)
	hurtbox.hurt.emit(self)

func _on_area_exited(hurtbox: Hurtbox) -> void:
	print("[Exit] %s => %s" % [name, hurtbox.owner.name])
	hurtbox.exit.emit()
