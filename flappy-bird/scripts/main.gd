extends Node2D

var current_level: Node2D = null
var levels: Dictionary = {
	"level_1":preload("res://scenes/level.tscn"),
}
var player = null
var camera = null 

@onready var menu: Node = $ui/menu
@onready var hud: Node = $ui/hud
var player_scene = preload("res://scenes/bird.tscn")
@onready var world: Node = $world


func _ready() -> void:
	player = player_scene.instantiate()
	camera = player.get_node("Camera2D")
	camera.enabled = false
	world.add_child(player)
	menu.level_changed.connect(load_level)
	player.game_over.connect(menu._on_game_over)
	#load_settings()

func load_level(index):
	if current_level:
		current_level.queue_free()
	var name = levels.keys()[index]
	current_level = levels[name].instantiate()
	world.add_child(current_level)
	player.global_position = current_level.get_node("spawn_point").global_position
	camera.enabled=true
	camera.limit_left=0
	camera.limit_top=0
	camera.limit_bottom=768
	current_level.camera = camera
	current_level.player = player
	current_level.hud = hud
	menu.restart.connect(current_level.restart)
	menu.restart.connect(hud.update_score)
	player.start_game()
	
func save_settings():
	var config = ConfigFile.new()
	var slider: HSlider = menu.get_node("CenterContainer/VBoxContainer/HBoxContainer/HSlider")
	config.set_value("audio","volume",slider.value)
	config.save("user://player.cfg")
	
func load_settings():
	var config = ConfigFile.new()
	var error = config.load("user://player.cfg")
	if error==OK:
		var slider: HSlider = menu.get_node("CenterContainer/VBoxContainer/HBoxContainer/HSlider")
		var volume = config.get_value("audio","volume",0.0)
		slider.value = volume
