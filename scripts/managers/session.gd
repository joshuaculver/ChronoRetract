extends Node

@onready var timer = $tickTimer

var turnCount : int = 0

##All ready signal
func _ready():
	managers.sessionManager = self
	managers.initSession()

func tick() -> void:
	turnCount = turnCount + 1
	if turnCount % 10 == 0:
		managers.militaryReport()
	##Engine.time_scale
	$units.tick()
	$regions.tick()
	$factions.tick()
