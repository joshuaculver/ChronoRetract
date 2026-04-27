class_name SessionManager

extends Node

@onready var timer = $tickTimer

var turnCount : int = 0

func tick() -> void:
	turnCount = turnCount + 1
	if turnCount % 10 == 0:
		managers.militaryReport()
	##Engine.time_scale
	$units.tick()
	$regions.tick()
	$factions.tick()

func startTimer():
	if timer.is_stopped():
		timer.start()
