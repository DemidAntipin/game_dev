extends Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var spawn:Marker2D = $spawn_point
@onready var obstacles = $obstacles
@export var obstacle_scene: PackedScene
@export var offscreen_distance:float = 300
var camera: Camera2D
var player: CharacterBody2D
var hud: Node
var spawned_obstacles: Array[Node]=[]
var right_x: float = globals.world_offset
var left_x:float = globals.world_offset

func _ready() -> void:
	globals.null_score()
	audio_player.play()
	var screen_size = get_viewport_rect().size
	right_x += screen_size.x
	
func _process(delta):
	if not camera or not player or not obstacle_scene:
		return
	var screen_size = get_viewport_rect().size
	var camera_position = camera.global_position
	var half_w = screen_size.x/2
	var left_edge = camera_position.x - half_w
	var right_edge = camera_position.x + half_w
	
	while right_x<right_edge+offscreen_distance:
		var shift = randi_range(-globals.shift_y, globals.shift_y)
		_spawn_obstacle(right_x+globals.gap, shift)
		right_x = spawned_obstacles[-1].global_position.x
	for obstacle in spawned_obstacles:
		if obstacle.position.x<left_edge - offscreen_distance:
			obstacle.queue_free()
			spawned_obstacles.pop_front()
	left_x = left_edge
	globals.world_offset = left_x
			
func _spawn_obstacle(x:float,shift:int):
	if not obstacle_scene:
		return
	var obstacle = obstacle_scene.instantiate()
	obstacle.global_position.x = x
	obstacle.global_position.y += shift
	obstacle.danger.connect(player.damage)
	obstacle.score.connect(hud.update_score)
	
	obstacles.add_child(obstacle)
	spawned_obstacles.append(obstacle)
	
func restart():
	for obstacle in obstacles.get_children():
		obstacle.queue_free()
	spawned_obstacles = []
	audio_player.stop()
	player.reset()
	globals.world_offset = 0
	left_x = 0
	right_x = get_viewport_rect().size.x
	player.global_position = get_node("spawn_point").global_position
	self.queue_free()
