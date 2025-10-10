extends Area2D

signal collided(collider_position)

@onready var window = get_parent().get_window()
@onready var size = get_node("enemy_sprite").texture.get_size()

var acceleration: Vector2 = Vector2(0, 0)
var velocity: Vector2 = Vector2(0, 0)
var max_force: float = 15000
var max_speed: float = 20000
@onready var max_distance: float = 512

func _process(delta: float) -> void:
	update(delta)
	if global_position.y - 100 < size.y/2:
		global_position.y = size.y/2 + 100
	if global_position.y > window.size.y - size.y/2:
		global_position.y = window.size.y - size.y/2

func apply_force(force: Vector2):
	acceleration = force

func seek(target: Vector2):
	var direction = target - global_position
	var k = remap(direction.length(), 0, max_distance, 1, 3)
	if direction.length() > max_distance:
		return
	var desired_velocity = direction.normalized() * max_speed
	var steering = (desired_velocity - velocity) * k
	steering = steering.limit_length(max_force)
	apply_force(steering)
	
func pursue(target: Vector2, target_velocity: Vector2):
	var direction = target - global_position
	var speed = velocity.length()
	if speed == 0:
		speed = max_speed
	var ahead_time = direction.length() / speed
	var predict = Vector2(0, 0)
	predict = target + target_velocity * ahead_time * 30
	if predict.y >= window.size.y - size.y/2 or predict.y <= size.y/2 + 100:
		var normalize = fmod((predict.y - 100), ((window.size.y - size.y - 100)*2))
		if normalize < 0:
			normalize += (window.size.y - size.y - 100) * 2
		if normalize <= (window.size.y - size.y - 100):
			predict.y = normalize + size.y/2 + 100
		else:
			predict.y = (window.size.y - size.y - 100)* 2 - normalize + size.y/2 + 100 
	seek(predict)

func update(delta: float):
	velocity.y += acceleration.y*delta
	velocity.x = 0
	velocity = velocity.limit_length(max_speed)
	global_position += velocity*delta
	acceleration *= 0
	velocity *= 0

func _on_ball_area_entered(area: Area2D) -> void:
	collided.emit(global_position)
