extends CharacterBody2D

const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0

enum State {IDLE, FALLING, JUMP, DEATH}

@onready var animation = get_node("AnimationPlayer")
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer

var current_state: State = State.IDLE

var initial_position: Vector2

signal game_over

func set_state(new_state: State):
	current_state = new_state
	
func _ready() -> void:
	initial_position = global_position
	set_state(State.IDLE)
	
	
func handle_idle(delta):
	animation.play("idle")
	velocity = Vector2.ZERO
		
func handle_jump(delta):
	animation.play("jump")
	velocity.x = 100
	if velocity.y > 0:
		set_state(State.FALLING)
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY

func handle_falling(delta):
	animation.play("idle")
	velocity.x = 100
	if Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_VELOCITY
		set_state(State.JUMP)

func handle_death(delta):
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.FALLING:
			handle_falling(delta)
		State.JUMP:
			handle_jump(delta)
		State.DEATH:
			handle_death(delta)
	move_and_slide()
	handle_collisions()

func reset():
	global_position = initial_position
	set_state(State.IDLE)

func damage():
	animation.animation_finished.connect(func(name): if name == "death": game_over.emit())
	animation.play("death")
	set_state(State.DEATH)
	#game_over.emit()
	
func start_game():
	velocity.x = 100
	set_state(State.FALLING)
	
func handle_collisions():	
	var collisions_count = get_slide_collision_count()
	for i in collisions_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if "border" in collider.name:
			damage()
		
