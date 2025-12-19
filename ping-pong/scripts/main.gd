extends Node2D

var current_level: Node2D = null
var levels: Dictionary = {
	"level_1":preload("res://scenes/level.tscn"),
}
var player = null

@onready var menu: Node = $ui/menu
@onready var hud: Node = $ui/hud
var player_scene = preload("res://scenes/player.tscn")
@onready var world: Node = $world


func _ready() -> void:
	player = player_scene.instantiate()
	world.add_child(player)
	menu.level_changed.connect(load_level)
	menu.reset_score.connect(globals.null_score)
	menu.restart.connect(hud.update_score)
	globals.zero_score.connect(hud.update_score)
	#load_settings()

func load_level(index):
	if current_level:
		current_level.queue_free()
	var name = levels.keys()[index]
	current_level = levels[name].instantiate()
	world.add_child(current_level)
	player.global_position = current_level.get_node("spawn_point").global_position
	current_level.player = player
	current_level.hud = hud
	menu.restart.connect(current_level.restart)
	current_level.game_over.connect(menu._on_game_over)
	current_level.get_node("AudioStreamPlayer").play()
	current_level.start_game()
	
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
