extends CharacterBody2D

enum State {IDLE, WALK}

@onready var animation_player: AnimationPlayer = $AnimationPlayer
var current_state: State = State.IDLE
var speed: float = 20000.0

func handle_idle(delta):
	animation_player.play("RESET")
	var direction = Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		current_state = State.WALK
		
func handle_walk(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	
	if (Input.is_action_pressed("right") || Input.is_action_pressed("left")):
		direction.y=0
	elif (Input.is_action_pressed("up") || Input.is_action_pressed("down")):
		direction.x=0
	if direction == Vector2.ZERO:
		current_state = State.IDLE
	direction = direction.normalized()
	if direction == Vector2.DOWN:
		animation_player.play("move_down")
	elif direction == Vector2.UP:
		animation_player.play("move_up")
	elif direction == Vector2.LEFT:
		animation_player.play("move_left")
	elif direction == Vector2.RIGHT:
		animation_player.play("move_right")
	velocity = direction * speed * delta

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.WALK:
			handle_walk(delta)
	move_and_slide()
