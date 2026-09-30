extends PathFollow2D

var arrow = preload("res://assets/sprites/arrow.png")

func _process(delta: float):
	progress = progress + (delta * 100)
