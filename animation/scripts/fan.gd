extends StaticBody2D

@onready var animation = get_node("")
@onready var area = get_node("Area2D/CollisionShape2D")
@onready var particles = get_node("GPUParticles2D")
@onready var audio: AudioStreamPlayer2D = get_node("fan_player")

func _ready() -> void:
	turn_on()

func turn_on():
	area.disabled = false
	particles.emitting = true
	audio.play()
	
	
func turn_off():
	area.disabled = true
	particles.emitting = false
	audio.stop()
