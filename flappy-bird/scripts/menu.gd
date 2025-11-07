extends CanvasLayer

signal restart

@onready var container = get_node("VBoxContainer")
@onready var play_button: Button = get_node("VBoxContainer/play")
@onready var continue_button: Button = get_node("VBoxContainer/continue")
@onready var to_main_button: Button = get_node("VBoxContainer/to_main")
@onready var exit_button: Button = get_node("VBoxContainer/exit")
	
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
