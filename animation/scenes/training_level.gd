extends Node2D

@onready var slime_1 = get_node("static/slime_1")
@onready var slime_2 = get_node("static/slime_2")
@onready var dude = get_parent().get_node("dude")
@onready var static_box_animation = get_node("static/static_box/AnimationPlayer")
@onready var audio: AudioStreamPlayer = get_node("AudioStreamPlayer")
@onready var fire_trap = get_node("static/fire_trap")
@onready var fire_trap_animation: AnimationPlayer = get_node("static/fire_trap/AnimationPlayer")

func _ready() -> void:
	dude.hit.connect(_on_hit_static_box)
	dude.jumped_to_slime.connect(_on_jump_to_slime)
	audio.stream = load("res://audio/background.ogg")
	audio.volume_db = linear_to_db(0.05)
	audio.play()
	dude.trapped.connect(_on_trap_activate)

func _on_jump_to_slime(name):
	if name == slime_1.name:
		slime_1.is_pressing = true
	elif name == slime_2.name:
		slime_2.is_pressing = true

func _on_trap_activate(name):
	fire_trap.burn_time = 3
	if fire_trap_animation.current_animation != "on_fire":
		fire_trap_animation.play("on_fire")

func _on_hit_static_box():
	static_box_animation.play("reaction")	
