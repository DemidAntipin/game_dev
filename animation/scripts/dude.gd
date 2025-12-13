extends Node2D

@onready var animation = get_node("dude_animation")
@onready var sprite = get_node("dude_sprite")

var speed: int = 100

var state: String = "idle"

func _process(delta: float) -> void:
	if state == "idle" and animation.current_animation != "idle":
		animation.play("idle")
	if state == "run" and animation.current_animation != "run":
		animation.play("run")
	if state == "jump" and animation.current_animation != "jump":
		animation.play("jump")
	if Input.is_action_pressed("ui_left"):
		state = "run"
		sprite.flip_h = true
		global_position.x -= speed * delta
	elif Input.is_action_pressed("ui_right"):
		state = "run"
		sprite.flip_h = false
		global_position.x += speed * delta
	elif Input.is_action_pressed("ui_up"):
		state = "jump"
	else:
		state = "idle"
