extends Area2D

signal danger

func _on_body_entered(body: Node2D) -> void:
	if body.name == "bird":
		danger.emit()
