extends Node2D

var current_level: Node2D = null
var levels: Dictionary = {"Training": preload("res://scenes/training_level.tscn"),
 "Infinity": preload("res://scenes/infinity.tscn")}
var dude = null
var camera = null

@onready var menu  = get_node("ui/menu")

@onready var player_scene = preload("res://scenes/physics_dude.tscn")
@onready var world = $world

func _ready() -> void:
	dude = player_scene.instantiate()
	dude.name = "dude"
	camera = dude.get_node("Camera2D")
	world.add_child(dude)
	menu.update_levels(levels.keys())
	menu.level_changed.connect(load_level)
	load_level(levels.keys()[0])
	load_settings()

func load_level(name):
	if current_level:
		current_level.queue_free()
	current_level = levels[name].instantiate()
	dude.global_position = current_level.get_node("spawn_point").global_position
	world.add_child(current_level)
	match name:
		"Training" : camera.enabled = false
		"Infinity" : 
			camera.enabled = true
			camera.limit_left = 0
			camera.limit_bottom = 648
			camera.limit_top = 0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if menu.visible:
			Globals.resume()
			menu.hide()
		else:
			Globals.pause()	
			menu.show()

func save_settings():
	var config = ConfigFile.new()
	var slider: HSlider = menu.get_node("CenterContainer/VBoxContainer/HBoxContainer/HSlider")
	config.set_value("audio", "volume", slider.value)
	config.save("user://dude.cfg")
	
func load_settings():
	var config: ConfigFile = ConfigFile.new()
	var error = config.load("user://dude.cfg")
	if error == OK:
		var slider: HSlider = menu.get_node("CenterContainer/VBoxContainer/HBoxContainer/HSlider")
		slider.value = config.get_value("audio", "volume", 0.8)
		slider.value_changed.emit(slider.value)
