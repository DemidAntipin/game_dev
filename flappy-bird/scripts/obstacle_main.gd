extends Node2D

signal score

var velocity: Vector2i = Vector2(0, 0)
var speed: int = 100
var rmd = RandomNumberGenerator.new()
@onready var window = get_parent().get_window()
@onready var size = get_node("obstacle_area/obstacle_background").texture.get_size()
var is_paused = false

func _ready() -> void:
	velocity = Vector2i(100, 0)
	add_to_group("obstacles")

func _process(delta: float) -> void:
	if is_paused:
		return
	global_position -= velocity*delta
	if global_position.x < -window.size.x-size.x:
		queue_free()

func set_pause(value: bool):
	is_paused = value
	set_process(!value)

func _on_score_area_body_entered(body: Node2D) -> void:
	score.emit()
