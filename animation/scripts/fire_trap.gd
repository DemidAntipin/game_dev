extends StaticBody2D

const FIRE_DURATION = 3

@onready var animation: AnimationPlayer = get_node("AnimationPlayer")
@onready var particles = get_node("GPUParticles2D")
var burn_time = 0

func _ready() -> void:
	animation.animation_started.connect(_trap_activate)
	animation.animation_finished.connect(_trap_deactivate)
	
func _trap_activate(name):
	if name == "on_fire":
		particles.emitting = true
		if burn_time == 0:
			burn_time = FIRE_DURATION
			
func _trap_deactivate(name):
	if name == "on_fire":
		particles.emitting = false
		burn_time -= 0.4
		if burn_time > 0:
			animation.play("on_fire")
		else:
			animation.play("idle")
			burn_time = 0
	
