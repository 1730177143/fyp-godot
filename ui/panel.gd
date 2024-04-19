extends Control

@export var stats: Stats


@onready var health_bar: TextureProgressBar = $StausPanel/V/Health/HealthBar
@onready var eased_health_bar: TextureProgressBar = $StausPanel/V/Health/HealthBar/EasedHealthBar
@onready var health_num: Label = $StausPanel/V/Health/HealthNum
@onready var energy_bar: TextureProgressBar = $StausPanel/V/Energy/EnergyBar
@onready var energy_num: Label = $StausPanel/V/Energy/EnergyNum
@onready var material_num: Label = $H/Material_num





func _ready() -> void:
	if not stats:
		stats = Game.player_stats
	
	stats.health_changed.connect(update_health)
	update_health(true)
	
	stats.energy_changed.connect(update_energy)
	update_energy()
	
	stats.material_changed.connect(update_material)
	update_material()
	
	# 4.2+
	tree_exited.connect(func ():
		stats.health_changed.disconnect(update_health)
		stats.energy_changed.disconnect(update_energy)
		stats.material_changed.disconnect(update_material)
	)


func update_health(skip_anim := false) -> void:
	var percentage := stats.health / float(stats.max_health)
	health_bar.value = percentage
	health_num.text=str(stats.health)
	if skip_anim:
		eased_health_bar.value = percentage
	else:
		create_tween().tween_property(eased_health_bar, "value", percentage, 0.3)


func update_energy() -> void:
	var percentage := stats.energy / stats.max_energy
	energy_bar.value = percentage
	energy_num.text= "%-.1f" % stats.energy

func update_material()->void:
	material_num.text=str(stats.material)
