extends Node2D

@onready var player = get_node("bird")
@onready var obstacle = preload("res://scenes/obstacle.tscn")
@onready var score_label = get_node("score")
@onready var menu = get_node("menu")
@onready var results = get_node("results")

var random = RandomNumberGenerator.new()
var spawn_timer: Timer
var time_left: float = 0
const SPAWN_INTERVAL = 3

enum State {IDLE, START_GAME, GAME_PAUSED, GAME, GAME_OVER}

var current_state: State = State.IDLE
var score = 0

func set_state(new_state: State):
	current_state = new_state

func handle_idle(delta):
	pass

func handle_start_game(delta):
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_obstacle)
	spawn_timer.start(SPAWN_INTERVAL)
	player.start_game()
	set_state(State.GAME)

func handle_game(delta):
	if Input.is_action_just_pressed("pause"):
		menu.visible = !menu.visible
		set_state(State.GAME_PAUSED)

func handle_game_over(delta):
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		obstacle.queue_free()
	player.reset()
	results.visible = true
	results.get_node("CenterContainer/VBoxContainer/score").text = "Your score: " + str(score)
	
func _ready() -> void:
	player.game_over.connect(_on_game_over)
	menu.get_node("CenterContainer/VBoxContainer/play").pressed.connect(_on_play_button_pressed)
	menu.get_node("CenterContainer/VBoxContainer/exit").pressed.connect(_on_exit_button_pressed)
	menu.get_node("CenterContainer/VBoxContainer/continue").pressed.connect(_on_continue_button_pressed)
	results.get_node("CenterContainer/VBoxContainer/new_game").pressed.connect(_on_play_button_pressed)
	results.get_node("CenterContainer/VBoxContainer/to_main").pressed.connect(_on_main_menu_button_pressed)
	results.get_node("CenterContainer/VBoxContainer/exit").pressed.connect(_on_exit_button_pressed)
	menu.restart.connect(_restart)
	menu.visible = true
	score_label.visible = false
	set_state(State.IDLE)

func _on_main_menu_button_pressed():
	results.visible = false
	menu.visible = true
	menu._main_menu()

func _on_play_button_pressed():
	menu.visible = false
	results.visible = false
	score = 0
	score_label.visible = true
	set_state(State.START_GAME)
	menu.start()

func _on_exit_button_pressed():
	get_tree().quit()
	
func _on_continue_button_pressed():
	menu.visible = false
	spawn_timer.wait_time = time_left
	spawn_timer.start()
	resume_obstacles()
	player.start_game()
	set_state(State.GAME)

func _spawn_obstacle() -> void:
	spawn_timer.wait_time = SPAWN_INTERVAL
	spawn_timer.start()
	var value = random.randi_range(-220, 220)
	var instance = obstacle.instantiate()
	instance.score.connect(_on_score)
	instance.get_node("obstacle_area").danger.connect(player.damage)
	instance.get_node("obstacle_area2").danger.connect(player.damage)
	instance.global_position.y += value
	add_child(instance)

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.START_GAME:
			handle_start_game(delta)
		State.GAME:
			handle_game(delta)
		State.GAME_OVER:
			handle_game_over(delta)
		State.GAME_PAUSED:
			handle_game_paused(delta)
	score_label.text = "Your score: " + str(score)

func handle_game_paused(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		menu.visible = !menu.visible
	if menu.visible:
		if !spawn_timer.is_stopped():
			time_left = spawn_timer.time_left
			spawn_timer.stop()
		pause_obstacles()
		player.set_state(State.IDLE)
	else:
		_on_continue_button_pressed()
	
func _on_score():
	score += 1

func _on_game_over():
	if spawn_timer != null:
		spawn_timer.stop()
	set_state(State.GAME_OVER)

func pause_obstacles():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		obstacle.set_pause(true)

func resume_obstacles():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		obstacle.set_pause(false)
		
func _restart():
	for obstacle in get_tree().get_nodes_in_group("obstacles"):
		obstacle.queue_free()
	score = 0
	player.reset()
	set_state(State.IDLE)
