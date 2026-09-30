extends Button

@onready var slider = $Slider
@onready var playPos = $PlayPos.position
@onready var pausePos = $PausePos.position

var tween
var paused = false

func makeTween():
	paused = !paused
	if paused:
		if position != pausePos:
			if tween != null:
				tween.kill()
			tween = create_tween()
			tween.tween_property(slider, "position", pausePos, 0.15).from_current()
	else:
		if position != playPos:
			if tween != null:
				tween.kill()
			tween = create_tween()
			tween.tween_property(slider, "position", playPos, 0.15).from_current()
