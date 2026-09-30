## Script name: CloudSpawner.gd
##
## Creates and controls cloud visuals

extends Node

## 1152x648

var rightPos = 1252
var leftPos = -100

##Negative moves to the left, positive moves to the right
var direction = -1.0
var spd = 2.0
var sec = 60

var cloudTime = randi_range(30 * sec, 300 * sec)

var cloudScene = preload("res://prefabs/visuals/cloud.tscn")

func _process(delta: float):
	if managers != null && managers.sessionManager != null:
		if !managers.sessionManager.timer.is_stopped():
			if cloudTime <= 0:
				cloudTime = randi_range(30 * sec, 300 * sec)
				newCloud()
			else:
				cloudTime = cloudTime - 1
			var clouds = get_children()
			for cloud in clouds:
				cloud.position = cloud.position + Vector2(delta * direction * spd, 0)

func newCloud() -> void:
	var new = cloudScene.instantiate()
	var height = randi_range(32, 616)
	if direction > 0:
		new.position = Vector2(leftPos, height)
	else:
		new.position = Vector2(rightPos, height)
	add_child(new)
