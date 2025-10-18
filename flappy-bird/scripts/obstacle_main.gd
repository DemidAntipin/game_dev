extends Node2D

var velocity: Vector2i = Vector2(0, 0)
var speed: int = 100
var rmd = RandomNumberGenerator.new()
@onready var window = get_parent().get_window()
@onready var size = get_node("obstacle_area/obstacle_area/obstacle_background").texture.get_size()

func _ready() -> void:
	velocity = Vector2i(100, 0)
	var obstacle_area = get_node("obstacle_area")

func _process(delta: float) -> void:
	global_position -= velocity*delta
	if global_position.x < -window.size.x-size.x:
		queue_free()
