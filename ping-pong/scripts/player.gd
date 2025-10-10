extends Node2D

var speed: int = 500
signal collided(collider_position)

@onready var window = get_parent().get_window()
@onready var size = get_node("player_sprite").texture.get_size()

func _process(delta: float) -> void:
	var movement: int = 0
	if Input.is_action_pressed("ui_up"):
		movement = -speed * delta
	if Input.is_action_pressed("ui_down"):
		movement = speed * delta
	global_position += Vector2(0, movement)
	if global_position.y - 100 < size.y/2:
		global_position.y = size.y/2 + 100
	if global_position.y > window.size.y - size.y/2:
		global_position.y = window.size.y - size.y/2

func _on_ball_area_entered(area: Area2D) -> void:
	collided.emit(global_position)
