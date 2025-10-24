extends Node2D

@onready var player = get_node("bird")
@onready var obstacle = preload("res://scenes/obstacle.tscn")
@onready var score_label = get_node("score")
var random = RandomNumberGenerator.new()
var spawn_timer: Timer
const SPAWN_INTERVAL = 3

enum State {IDLE, START_GAME, GAME, GAME_OVER}

var current_state: State = State.IDLE
var score = 0

func set_state(new_state: State):
	current_state = new_state

func handle_idle(delta):
	if Input.is_action_just_pressed("jump"):
		set_state(State.START_GAME)

func handle_start_game(delta):
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_obstacle)
	spawn_timer.start(SPAWN_INTERVAL)
	player.start_game()
	set_state(State.GAME)

func handle_game(delta):
	score_label.text = "Your score: " + str(score)

func handle_game_over(delta):
	print("Your score: ", score)
	
func _ready() -> void:
	player.game_over.connect(_on_game_over)
	set_state(State.IDLE)

func _spawn_obstacle() -> void:
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

func _on_score():
	score += 1

func _on_game_over():
	if spawn_timer != null:
		spawn_timer.stop()
	set_state(State.GAME_OVER)
