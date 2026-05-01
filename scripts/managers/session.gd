class_name SessionManager

extends Node

@onready var timer = $tickTimer

var turnCount : int = 0

##factions
##regions

var factions = preload("res://prefabs/managers/factions.tscn")
var regions = preload("res://prefabs/managers/regions.tscn")

func _ready():
	var newFactions = factions.instantiate()
	add_child(newFactions)
	
	var newRegions = regions.instantiate()
	add_child(newRegions)

func tick() -> void:
	turnCount = turnCount + 1
	if turnCount % 10 == 0:
		managers.militaryReport()
	##Engine.time_scale
	$units.tick()
	$regions.tick()
	$factions.tick()
	$battles.tick()
	
	##DEBUG
	##
	if turnCount == 2:
		managers.battleManager.createWar(managers.factionDict[enums.Factions.RED], managers.factionDict[enums.Factions.GREEN])

func startTimer():
	if timer.is_stopped():
		timer.start()
