extends Node2D

@onready var player = get_node("bird")
@onready var obstacle = preload("res://scenes/obstacle.tscn")
var random = RandomNumberGenerator.new()
const SPAWN_INTERVAL = 3


func _ready() -> void:
	var spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.timeout.connect(_spawn_obstacle)
	spawn_timer.start(SPAWN_INTERVAL)

func _spawn_obstacle() -> void:
	var value = random.randi_range(-220, 220)
	var instance = obstacle.instantiate()
	instance.get_node("obstacle_area").danger.connect(player.damage)
	instance.global_position.y += value
	add_child(instance)
