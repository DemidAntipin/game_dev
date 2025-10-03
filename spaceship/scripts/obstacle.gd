extends Area2D

signal danger

var angular_velocity: float = 1.0
var velocity: Vector2i = Vector2(0, 0)
var rmd = RandomNumberGenerator.new()
@onready var window = get_parent().get_window()
@onready var size = get_node("asteroid_sprite").texture.get_size()

func _ready() -> void:
	velocity = Vector2i(rmd.randi_range(-300, 300), rmd.randi_range(-300, 300))
	angular_velocity = rmd.randf_range(1, 5)

func _process(delta: float) -> void:
	global_position += velocity*delta
	rotation += angular_velocity*delta
	if global_position.x >= window.size.x - size.x/2:
		velocity.x *= -1
	elif global_position.y >= window.size.y - size.y/2:
		velocity.y *= -1
	elif global_position.x <= size.x/2:
		velocity.x *= -1
	elif global_position.y <= size.y/2:
		velocity.y *= -1

func _on_asteroid_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		danger.emit()
