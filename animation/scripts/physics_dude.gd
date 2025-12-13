extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0
const GRAVITY = 800.0
const STUN_TIME = 0.5
var double_jumped = true
var interactive = null
enum State {IDLE, RUN, JUMP, DOUBLE_JUMP, STUN}

@onready var animation = get_node("dude_animation")
@onready var sprite = get_node("dude_sprite")
@onready var step_audio: AudioStreamPlayer = get_node("step_player")
@onready var jump_audio: AudioStreamPlayer = get_node("jump_player")

signal hit
signal jumped_to_slime
signal trapped

var current_state: State = State.IDLE
var stun_delay = 0

func set_state(new_state: State):
	current_state = new_state
	print(current_state)

func _ready() -> void:
	set_state(State.IDLE)

func handle_idle(delta):
	animation.play("idle")
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		set_state(State.RUN)
	else:
		velocity.x = 0 
		#velocity.x = move_toward(velocity.x, 0, SPEED/40)
	if Input.is_action_just_pressed("up"):
		velocity.y = JUMP_VELOCITY
		double_jumped = true
		jump_audio.play()
		set_state(State.JUMP)
		
func handle_run(delta):
	animation.play("run")
	if not step_audio.playing and is_on_floor():
		step_audio.play()
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
	else: 
		set_state(State.IDLE)
		return
	if Input.is_action_just_pressed("up"):
		velocity.y = JUMP_VELOCITY
		double_jumped = true
		jump_audio.play()
		set_state(State.JUMP)
	
func handle_jump(delta):
	animation.play("jump")
	if Input.is_action_just_pressed("up") and double_jumped:
		velocity.y = JUMP_VELOCITY
		double_jumped = false
		set_state(State.DOUBLE_JUMP)
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = lerp(velocity.x, direction*SPEED, 0.2)
		
func handle_double_jump(delta):
	animation.play("double_jump")
	if velocity.y > 0:
		set_state(State.JUMP)
	var direction = Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = lerp(velocity.x, direction*SPEED, 0.2)

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.RUN:
			handle_run(delta)
		State.JUMP:
			handle_jump(delta)
		State.DOUBLE_JUMP:
			handle_double_jump(delta)
		State.STUN:
			handle_stun(delta)
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	update_flip()	
	move_and_slide()
	handle_collisions(delta)
	
	if is_on_floor() and current_state in [State.JUMP, State.DOUBLE_JUMP]:
		if abs(velocity.x)>0:
			set_state(State.RUN)
		else:
			set_state(State.IDLE)

func handle_stun(delta):
	if stun_delay <= 0:
		set_state(State.IDLE)
	else:
		stun_delay -= delta

func handle_collisions(delta):	
	var platform = null
	var collisions_count = get_slide_collision_count()
	for i in collisions_count:
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		var normal = collision.get_normal()
		if "static_box" in collider.name:
			if abs(normal.y) > 0.8:
				var force = 4
				if normal.y < 0:
					force = 2
				hit.emit()
				velocity = normal * SPEED * force
				jump_audio.play()
				set_state(State.JUMP)
		elif "wall" in collider.name:
			if abs(normal.x)>0.8:
				velocity = normal * SPEED
				stun_delay = STUN_TIME
				set_state(State.STUN)
		if "plank" in collider.name:
			platform = collider
		if "slime" in collider.name:
			if abs(normal.y) > 0.8:
				jumped_to_slime.emit(collider.name)
		if "trap" in collider.name:
			if abs(normal.y) > 0.8:
				var force = 2
				trapped.emit(collider.name)
				velocity = normal * SPEED * force
	if Input.is_action_just_pressed("down"):
		var collision = platform.get_child(0)
		collision.disabled = true
		await get_tree().create_timer(0.1).timeout
		collision.disabled = false

func update_flip():
	sprite.flip_h = velocity.x < 0
