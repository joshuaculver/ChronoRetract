## Script name: session.gd
##
## Manages the top level game state and calling game elements to "take their turn" every tick
class_name SessionManager

extends Node

## Timer which indicates when a tick should be processed
@onready var timer = $tickTimer

var turnCount : int = 0 :
	get:
		return turnCount
	set(value):
		turnCount = value
		ticked.emit(value)

## Scenes for the initial states of the factions and regions of the map respectively
var factions = preload("res://prefabs/managers/factions.tscn")
var regions = preload("res://prefabs/managers/regions.tscn")

signal ticked(value)

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

##Toggles pausing and unpausing the game timer which causes ticks to occur
func timerToggle() -> void:
	if timer != null:
		if timer.is_stopped():
			timerActive(true)
			print("time unpaused")
		else:
			timerActive(false)
			print("time paused")

##Sets timer to passed state
func timerActive(setting : bool):
	if timer != null:
		if setting:
			timer.start()
		else:
			timer.stop()
