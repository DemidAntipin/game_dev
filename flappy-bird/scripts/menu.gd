extends Panel

signal restart

@onready var container = get_node("CenterContainer/VBoxContainer")
@onready var play_button: Button = container.get_node("play")
@onready var continue_button: Button = container.get_node("continue")
@onready var to_main_button: Button = container.get_node("to_main")
@onready var exit_button: Button = container.get_node("exit")
	
func _ready() -> void:
	to_main_button.pressed.connect(_main_menu)
	
func start() -> void:
	play_button.visible=false
	continue_button.visible=true
	to_main_button.visible=true

func _main_menu() -> void:
	play_button.visible=true
	continue_button.visible=false
	to_main_button.visible=false
	restart.emit()
