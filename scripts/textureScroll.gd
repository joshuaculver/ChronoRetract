## Script name: textureScroll.gd
##
## Creates an animated visual texture effect

extends Polygon2D

var target : Vector2 = Vector2(0, 0)

func _process(delta: float) -> void:
	if (texture_offset.x - target.x) < 5 and (texture_offset.y - target.y) < 5:
		newTarget()
	else:
		texture_offset = texture_offset.lerp(target, delta * 0.1)

func newTarget():
	target.x = randf_range(-50.0, 50.0)
	target.y = randf_range(-50.0, 50.0)
