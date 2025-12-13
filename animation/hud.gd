extends Node

@export var heath_texture: Texture2D

func _ready() -> void:
	update_health()

func update_health():
	var container: HBoxContainer = get_node("Panel/HBoxContainer")
	if container:
		for child in container.get_children():
			child.queue_free()
		for i in Globals.max_health:
			var hp = TextureRect.new()
			hp.texture = heath_texture
			hp.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT
			container.add_child(hp)
