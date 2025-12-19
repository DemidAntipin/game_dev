extends Node2D

signal collided

var velocity: Vector2i = Vector2(0, 0)
var rmd = RandomNumberGenerator.new()
var acceleration_coef: float = 1.002
@onready var window = get_parent().get_window()
@onready var size = get_node("ball_area/ball_sprite").texture.get_size()

func _ready() -> void:
	velocity = Vector2i(rmd.randf_range(-4, 4)*100, rmd.randf_range(-4, 4)*100)

func reset() -> void:
	velocity = Vector2i(rmd.randf_range(-4, 4)*100, rmd.randf_range(-4, 4)*100)

func _process(delta: float) -> void:
	global_position += velocity*delta
	if global_position.y >= window.size.y - size.y/4:
		velocity.y *= -1
	elif global_position.y <= size.y/4:
		velocity.y *= -1

func bounce(collider_position: Vector2) -> void:
	var old_speed = velocity.length() * acceleration_coef
	var direction = collider_position - global_position
	velocity = -direction.normalized() * old_speed
