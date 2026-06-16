## Script name: cameraControl.gd
##
## Handles controllable camera
class_name cameraControl

extends Camera2D

var dragging = false

func _input(event: InputEvent) -> void:
	if managers.menuLock == false:
		if event.is_action("map_hold"):
			if event.is_pressed():
				dragging = true
			else:
				dragging = false
		elif event is InputEventMouseMotion and dragging:
			var newPos = global_position - event.screen_relative
			newPos.x = clamp(newPos.x, 250, 915)
			newPos.y = clamp(newPos.y, 100, 515)
			global_position = newPos
		
		if event.is_action("zoomIn"):
			if event.is_pressed():
				var newZoom = Vector2(zoom)
				newZoom.x = clamp(zoom.x + 0.2, 1, 2.4)
				newZoom.y = newZoom.x
				zoom = newZoom
		elif event.is_action("zoomOut"):
			if event.is_pressed():
				var newZoom = Vector2(zoom)
				newZoom.x = clamp(zoom.x - 0.2, 1, 2.4)
				newZoom.y = newZoom.x
				zoom = newZoom
