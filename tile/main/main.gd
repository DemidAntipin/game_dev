extends Node2D

@onready var player_scene = preload("res://scenes/player/player.tscn")

func _ready() -> void:
	var player = player_scene.instantiate()
	GameWorld._set_player(player)
	GameWorld._set_world($world)
	GameWorld._load_level("meadow")
	$world.add_child(player)
