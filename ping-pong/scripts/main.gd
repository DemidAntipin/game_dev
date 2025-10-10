extends Node2D

@onready var player = get_node("player/player_area")
@onready var ball = get_node("ball")
@onready var enemy = get_node("enemy/enemy_area")

func _ready() -> void:
	player.collided.connect(ball.bounce)
	enemy.collided.connect(ball.bounce)

func _process(delta: float) -> void:
	enemy.pursue(ball.global_position, ball.velocity)
