extends Node
## Script name: managers.gd
##
## This script is the top level game manager and handles initializing the rest of the managers
## This script should be global for the project. This also allows it to function as a singleton

## Manages UI elements and menus
var UImanager
## Top level manager for elements that are tracked by session or need saving
var sessionManager
var factionManager
var regionManager
var unitManager
var battleManager

##Reference for existing units and factions.
var factionDict = {}
var unitDict = {}
var unitID = 0

## Basic unit which is used for creating generic armies for all factions
var unitScene = preload("res://prefabs/units/army.tscn")
## The scene which is used to load the overall map, regions, and factions in their initial state
var sessScene = preload("res://prefabs/session.tscn")

func _ready():
	var session = sessScene.instantiate()
	add_child(session)
	
	UImanager = $UI
	sessionManager = $session
	factionManager = $session/factions
	regionManager = $session/regions
	unitManager = $session/units
	battleManager = $session/battles
	
	regionManager.init()
	factionManager.init()
	
	unitManager.addPlayer()

func addFaction(faction: Faction):
	if factionDict.has(faction):
		print("Faction already added")
	else:
		factionDict[faction.faction] = faction

func addUnit(unit : Unit):
	if unitDict.has(unit):
		print("Unit already added")
		return 0
	else:
		var ID = unitID
		unitDict[unitID] = unit
		
		##Connecting unit signals to managers
		unit.relocated.connect(unitMoved)
		unit.destroyed.connect(removeUnit)
		battleManager.unitConnect(unit)
		
		unitID = unitID + 1
		print("new unit ID: " + str(ID))
		return ID

## When a unit arrives at a new region they send a signal which calls this function
## Allows appropriate references to be established
func unitMoved(unitID : int, regionID : int, lastRegionID : int):
	var region = regionManager.regionDict[regionID]
	var oldRegion = regionManager.regionDict[lastRegionID]
	var unit = unitDict[unitID]
	
	var oldIndex = oldRegion.units.find(unit)
	if oldIndex != -1:
		oldRegion.units.remove_at(oldIndex)

	region.units.append(unit)
	region.notify_property_list_changed()

## Called by factions when attempting to create a new unit
##TODO move to appropriate manager
func tryMakeUnit(callFaction : enums.Factions, resources: int, size : enums.UnitSize):
	var faction = factionDict[callFaction]
	var amount = int(resources / faction.unitCost)

	var newUnit = unitScene.instantiate()
	
	newUnit.relocated.connect(unitMoved)
	newUnit.selected.connect(managers.unitManager.unitSelected)
	newUnit.destroyed.connect(removeUnit)

	unitManager.add_child(newUnit)
	
	faction.resources = faction.resources - (amount * faction.unitCost)
	
	newUnit.maxPower = amount * 100
	newUnit.power = amount * 100
	newUnit.faction = faction.faction
	newUnit.location = faction.ownedRegions[0]
	newUnit.modulate = enums.colorDict[faction.faction]
	
	newUnit.position = faction.ownedRegions[0].position
	newUnit.name = "Unit: " + str(newUnit.ID)
	
	faction.ownedRegions[0].units.append(newUnit)
	faction.ownedUnits.append(newUnit)
	
	unitManager.updateUnits()
	
	print("Faction: " + str(name) + " made unit" + " | " + "POW: " + str(newUnit.maxPower))

## Cleans up references to units which are removed
##TODO move to appropriate manager
func removeUnit(unit : Unit):
	unit.location.removeUnit(unit)
	factionDict[unit.faction].removeUnit(unit)
	unitDict.erase(unit.ID)

	unitManager.updateUnits()

## Creates a report of relative military power of all factions
func militaryReport():
	var factions = factionManager.factionArr
	
	var highest = float(0)
	for i in factions.size():
		if factions[i].faction != 5 && factions[i].militaryPow >= highest:
			highest = factions[i].militaryPow
	
	print("Highest pow: " + str(highest))
	
	var scoreDict = {
		enums.Factions.RED:float(0),
		enums.Factions.BLUE:float(0),
		enums.Factions.GREEN:float(0),
		enums.Factions.YELLOW:float(0),
		enums.Factions.PURPLE:float(0),
	}
	
	for i in factions.size():
		if factions[i].faction != 5 && highest != 0 && factions[i].militaryPow != 0:
			scoreDict[factions[i].faction] = snapped((float(factions[i].militaryPow) / float(highest)),0.01)
	
	print(str(scoreDict))

## Called by the menu for player navigation
##TODO move to appropriate manager
func _on_select_region_button_pressed() -> void:
	managers.unitManager.player.getPathRegion(regionManager.selectedRegion)
