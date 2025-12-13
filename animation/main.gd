extends Node2D

@onready var slime_1 = get_node("static/slime_1")
@onready var slime_2 = get_node("static/slime_2")
#@onready var slime_animation = get_node("bloobe/slime_animation")
@onready var dude = get_node("physics_dude")
@onready var static_box_animation = get_node("static/static_box/AnimationPlayer")

func _ready() -> void:
	#slime_animation.play("appear")
	#slime_animation.animation_finished.connect(_on_appear_ended)
	dude.hit.connect(_on_hit_static_box)
	dude.jumped_to_slime.connect(_on_jump_to_slime)

#func _on_appear_ended(name):
#	if name=="appear":
#		slime_animation.play("pressed")

func _on_jump_to_slime(name):
	if name == slime_1.name:
		slime_1.is_pressing = true
	elif name == slime_2.name:
		slime_2.is_pressing = true

func _on_hit_static_box():
	static_box_animation.play("reaction")
