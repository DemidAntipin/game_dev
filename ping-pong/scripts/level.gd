extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var spawn:Marker2D = $spawn_point
@onready var enemy = $objects/enemy
@onready var ball = $objects/ball
var player: CharacterBody2D
var hud: Node
var current_state: State = State.IDLE

var screen_size: Vector2i

signal game_over(win:bool)

enum State {IDLE, GAME}

func set_state(new_state: State):
	current_state = new_state

func handle_idle(delta):
	pass
	
func handle_game(delta):
	if ball.global_position.x < 0:
		game_over.emit(false)
		set_state(State.IDLE)
		restart()
	if ball.global_position.x > screen_size.x:
		globals.score +=100
		hud.update_score()
		ball.global_position = $objects/ball_spawn_point.global_position
		ball.reset()
	if not audio_player.playing:
		game_over.emit(true)
		set_state(State.IDLE)
		restart()

func start_game():
	player.collided.connect(ball.bounce)
	$objects/enemy/enemy_area.collided.connect(ball.bounce)
	audio_player.play()
	set_state(State.GAME)

func _ready() -> void:
	screen_size = get_viewport_rect().size
	ball.global_position = $objects/ball_spawn_point.global_position
	enemy.global_position = Vector2(screen_size.x-spawn.global_position.x, spawn.global_position.y)
	enemy.get_node("enemy_area").window = screen_size
	
func _process(delta):
	if not player:
		return
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.GAME:
			$objects/enemy/enemy_area.pursue(ball.global_position, ball.velocity)
			handle_game(delta)

func restart():
	player.reset()
	ball.global_position = $objects/ball_spawn_point.global_position
	enemy.global_position = Vector2(screen_size.x-spawn.global_position.x, spawn.global_position.y)
	player.global_position = get_node("spawn_point").global_position
	self.queue_free()
