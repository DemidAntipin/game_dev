extends CharacterBody2D

var speed: int = 500
signal collided(collider_position)

var initial_position: Vector2
var window = null
@onready var size = (func():
		var texture = $player_sprite
		if texture and texture.region_enabled: 
			return texture.region_rect.size * texture.scale 
		else:
			return texture.get_size() * texture.scale).call()

func _ready() -> void:
	window = get_viewport_rect().size
	initial_position = global_position

@onready var animation: AnimationPlayer = get_node("AnimationPlayer")

func _physics_process(delta: float) -> void:
	if not animation.is_playing():
		animation.play("idle")
	var movement: int = 0
	if Input.is_action_pressed("up"):
		movement = -speed * delta
	if Input.is_action_pressed("down"):
		movement = speed * delta
	global_position += Vector2(0, movement)
	if global_position.y < size.y/2:
		global_position.y = size.y/2
	if global_position.y > window.y - size.y/2:
		global_position.y = window.y - size.y/2
	move_and_slide()

func _on_ball_area_entered(area: Area2D) -> void:
	animation.stop()
	animation.play("hit")
	collided.emit(global_position)

func reset():
	global_position = initial_position
