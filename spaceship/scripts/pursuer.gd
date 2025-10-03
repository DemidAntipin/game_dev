extends Node2D

var acceleration: Vector2 = Vector2(0, 0)
var velocity: Vector2 = Vector2(0, 0)
var max_force: float = 1500
var max_speed: float = 600
var max_distance: float = 200
@onready var window = get_parent().get_window()
@onready var size = get_node("enemy_area/enemy_sprite").texture.get_size()

func apply_force(force: Vector2):
	acceleration = force
	
func seek(target: Vector2):
	var direction = target - global_position
	var k = remap(direction.length(), 0, max_distance, 0, 1)
	if direction.length() > max_distance:
		return
	var desired_velocity = direction.normalized() * max_speed
	var steering = (desired_velocity - velocity) * k
	steering = steering.limit_length(max_force)
	apply_force(steering)
	
func flee(target: Vector2):
	var direction = global_position - target
	if direction.length() > max_distance:
		return
	var desired_velocity = direction.normalized() * max_speed
	var steering = (desired_velocity - velocity)
	steering = steering.limit_length(max_force)
	apply_force(steering)
	
func update(delta: float):
	velocity += acceleration*delta
	velocity = velocity.limit_length(max_speed)
	global_position += velocity*delta
	acceleration *= 0
	rotation = velocity.angle() - PI/2
	
func _process(delta: float) -> void:
	update(delta)
	if global_position.x > window.size.x+size.x:
		global_position.x = -size.x
	elif global_position.y > window.size.y+size.y:
		global_position.y = -size.y
	elif global_position.x < -size.x:
		global_position.x = window.size.x+size.x
	elif global_position.y < -size.y:
		global_position.y = window.size.y+size.y
