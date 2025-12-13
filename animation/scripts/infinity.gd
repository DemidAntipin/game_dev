extends Node2D

@onready var audio = $AudioStreamPlayer2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	audio.stream = load("res://audio/background_2.ogg")
	audio.volume_db = linear_to_db(0.05)
	audio.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
