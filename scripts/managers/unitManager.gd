## Script name: unitManager.gd
##
## Manages references to units and units themselves
## All existing units will be children of this script's node
extends Node

## The selected unit for UI and menus if any
var selectedUnit : Unit

var playerScene = preload("res://prefabs/units/player.tscn")

var player : Player 

## Basic unit which is used for creating generic armies for all factions
var unitScene = preload("res://prefabs/units/army.tscn")

## Iterates through all units and calls their function for them to perform an action
func tick() -> void:
	var unitArr = get_children()
	for i in unitArr.size():
		if unitArr[i] != null:
			unitArr[i].tick()

##Creates a new unit and handles assigning it to a faction
func createUnit(callFaction : enums.Factions, size : enums.UnitSize):
	var faction : Faction = managers.factionDict[callFaction]
	var newUnit = unitScene.instantiate()
	
	newUnit.unitSize = size

	add_child(newUnit)
	
	newUnit.maxPower = enums.powerVals[size] * faction.powerBonus
	newUnit.power = enums.powerVals[size] * faction.powerBonus
	newUnit.faction = faction.faction
	newUnit.location = faction.ownedRegions[0]
	newUnit.modulate = enums.colorDict[faction.faction]
	
	newUnit.position = faction.ownedRegions[0].position
	newUnit.name = "Unit: " + str(newUnit.ID)
	
	faction.ownedRegions[0].units.append(newUnit)
	faction.ownedUnits.append(newUnit)
	faction.reportScore()
	
	managers.militaryReport()
	print("Faction: " + str(faction) + " made unit" + " | " + "POW: " + str(newUnit.maxPower) + " - Faction POW:" + str(faction.militaryPow))

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
