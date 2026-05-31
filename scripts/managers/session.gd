## Script name: session.gd
##
## Manages the top level game state and calling game elements to "take their turn" every tick
class_name SessionManager

extends Node

## Timer which indicates when a tick should be processed
@onready var timer = $tickTimer

var turnCount : int = 0

## Scenes for the initial states of the factions and regions of the map respectively
var factions = preload("res://prefabs/managers/factions.tscn")
var regions = preload("res://prefabs/managers/regions.tscn")

func _ready():
	var newFactions = factions.instantiate()
	add_child(newFactions)
	
	var newRegions = regions.instantiate()
	add_child(newRegions)

## Core "tick" function. Calls other managers to process all of their elements
func tick() -> void:
	turnCount = turnCount + 1
	if turnCount % 10 == 0:
		managers.militaryReport()
	##Engine.time_scale
	$units.tick()
	$regions.tick()
	$factions.tick()
	$battles.tick()
	
	##DEBUG for war testing
	if turnCount == 2:
		managers.battleManager.createWar(managers.factionDict[enums.Factions.RED], managers.factionDict[enums.Factions.GREEN])
