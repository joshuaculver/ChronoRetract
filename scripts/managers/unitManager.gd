## Script name: unitManager.gd
##
## Manages references to units and units themselves
## All existing units will be children of this script's node
extends Node

## The selected unit for UI and menus if any
var selectedUnit : Unit

var playerScene = preload("res://prefabs/units/player.tscn")
var player : Player 

## Iterates through all units and calls their function for them to perform an action
func tick() -> void:
	var unitArr = get_children()
	for i in unitArr.size():
		if unitArr[i] != null:
			unitArr[i].tick()

## Creates the player unit and adds it to a region on the map
func addPlayer():
	player = playerScene.instantiate()
	add_child(player)
	##Arbitary region for testing
	player.location = managers.regionManager.regionArr[3]
	player.position = managers.regionManager.regionArr[3].position
	
	player.changed.connect(managers.UImanager.playerUpdate)

func unitSelected(unit : Unit) -> void:
	if selectedUnit != unit:
		selectedUnit = unit
	else:
		selectedUnit = null
