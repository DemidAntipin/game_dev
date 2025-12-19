extends Node2D

signal restart
signal level_changed
signal reset_score

@onready var container = get_node("CenterContainer/VBoxContainer")
@onready var play_button: Button = container.get_node("play")
@onready var continue_button: Button = container.get_node("continue")
@onready var to_main_button: Button = container.get_node("to_main")
@onready var exit_button: Button = container.get_node("exit")

func _ready() -> void:
	get_node("results/CenterContainer/VBoxContainer/new_game").pressed.connect(_on_play_pressed)
	get_node("results/CenterContainer/VBoxContainer/to_main").pressed.connect(_on_to_main_pressed)
	get_node("results/CenterContainer/VBoxContainer/exit").pressed.connect(_on_exit_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			globals.resume()
			hide()
		else:
			globals.pause()
			show()

func _on_resume_button_pressed() -> void:
	globals.resume()
	hide()

func _on_exit_button_pressed() -> void:
	globals.exit()

func _on_to_main_pressed() -> void:
	globals.resume()
	$filter.visible = false
	reset_score.emit()
	get_node("results").visible = false
	container.visible = true
	play_button.visible=true
	continue_button.visible=false
	to_main_button.visible=false
	$AudioStreamPlayer.stream = load("res://assets/audio/main_menu_theme.mp3")
	$AudioStreamPlayer.play()
	restart.emit()

func _on_play_pressed() -> void:
	$results.visible = false
	$filter.visible = true
	container.visible = true
	play_button.visible=false
	continue_button.visible=true
	to_main_button.visible=true
	$AudioStreamPlayer.stop()
	level_changed.emit(globals.level_index)
	hide()

func _on_game_over() -> void:
	show()
	$AudioStreamPlayer.stream = load("res://assets/audio/losing_theme.mp3")
	$AudioStreamPlayer.play()
	$results/CenterContainer/VBoxContainer/score.text = "Score: " + str(globals.score)
	$results.visible = true
	container.visible = false
	
func _process(delta: float) -> void:
	global_position.x = globals.world_offset
