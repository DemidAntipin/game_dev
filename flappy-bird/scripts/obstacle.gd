extends Area2D

signal danger

func _on_area_entered(area: Area2D) -> void:
	danger.emit()
