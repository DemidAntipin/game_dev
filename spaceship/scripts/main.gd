extends Node2D

@onready var player = get_node("Player")
@onready var obstacle = get_node("obstacle/asteroid_area")
@onready var enemy = get_node("enemy")

func _ready() -> void:
	obstacle.danger.connect(player.damage)
	
func _process(delta: float) -> void:
	enemy.seek(player.global_position)
	enemy.seek(obstacle.global_position)
