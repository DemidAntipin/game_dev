extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0

enum State {IDLE, FALLING, JUMP, DEATH}

var current_state: State = State.IDLE

signal game_over

func set_state(new_state: State):
	current_state = new_state
	
func _ready() -> void:
	set_state(State.IDLE)
	
func handle_idle(delta):
	#animation.play("idle")
	pass
		
func handle_jump(delta):
	#animation.play("jump")
	if velocity.y > 0:
		set_state(State.FALLING)
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

func handle_falling(delta):
	#animation.play("falling")
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		set_state(State.JUMP)

func handle_death(delta):
	#animation.play("death")
	print("you lose")
	game_over.emit()

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.FALLING:
			handle_falling(delta)
		State.JUMP:
			handle_jump(delta)
		State.DEATH:
			handle_death(delta)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
		
	move_and_slide()

func damage():
	set_state(State.DEATH)
	
func start_game():
	set_state(State.FALLING)
