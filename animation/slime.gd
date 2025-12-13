extends StaticBody2D

@onready var slime_animation = get_node("AnimationPlayer")

enum State {IDLE, PRESSING, PRESSED}

var is_pressing = false

var current_state: State = State.IDLE

func set_state(new_state: State):
	current_state = new_state
	print(current_state)

func _ready() -> void:
	slime_animation.animation_finished.connect(_on_animation_finished)
	set_state(State.IDLE)

func _on_animation_finished(name):
	if name == "pressing":
		set_state(State.PRESSED)

func _process(delta: float) -> void:
	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.PRESSING:
			handle_pressing(delta)
		State.PRESSED:
			handle_pressed(delta)

func handle_idle(delta):
	slime_animation.play("idle")
	if is_pressing:
		set_state(State.PRESSING)
		
func handle_pressing(delta):
	slime_animation.play("pressing")
	
func handle_pressed(delta):
	slime_animation.play("pressed")

func _on_pressing():
	set_state(State.PRESSING)
	
	
	
