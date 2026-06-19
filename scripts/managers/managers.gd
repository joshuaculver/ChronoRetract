## Script name: managers.gd
##
## This script is the top level game manager and handles initializing the rest of the managers
## This script should be global for the project. This also allows it to function as a singleton
extends Node

## Manages UI elements and menus
var UImanager
## Top level manager for elements that are tracked by session or need saving
var sessionManager
var factionManager
var regionManager
var unitManager
var battleManager

## Used to disable input/interactions when main menu is open
var menuLock : bool = true

@onready var background : Node2D
@onready var UIcanvas : CanvasLayer

##Reference for existing units and factions.
var factionDict = {}
var unitDict = {}
var unitID = 0

var activeSession

## Basic unit which is used for creating generic armies for all factions
var unitScene = preload("res://prefabs/units/army.tscn")
## The scene which is used to load the overall map, regions, and factions in their initial state
var sessScene = preload("res://prefabs/session.tscn")

var scoreDict = {
		enums.Factions.RED:float(0),
		enums.Factions.BLUE:float(0),
		enums.Factions.GREEN:float(0),
		enums.Factions.YELLOW:float(0),
		enums.Factions.PURPLE:float(0),
	}

func _ready():
	UImanager = $UI
	background = $Background
	UIcanvas = $UI/UIcanvas

func _input(event: InputEvent) -> void:
	if activeSession != null:
		if event.is_action("escape"):
			if event.is_pressed():
				UImanager.mainMenuToggle()
				sessionManager.timerToggle()
				menuLockToggle()

func startSession():
	activeSession = sessScene.instantiate()
	
	UIcanvas.visible = true
	background.visible = true
	
	add_child(activeSession)
	sessionManager = $session
	factionManager = $session/factions
	regionManager = $session/regions
	unitManager = $session/units
	battleManager = $session/battles
	
	regionManager.init()
	factionManager.init()
	
	regionManager.sendResources.connect(factionManager.dispenseIncome)
	
	unitManager.addPlayer()
	unitManager.player.playerDefeated.connect(endRun)
	
	UImanager.mainMenuToggle()
	menuLockToggle()
	militaryReport()
	sessionManager.timerToggle()

func menuLockToggle() -> void:
	menuLock = !menuLock
	print("Menu lock: " + str(menuLock))

##TODO handle any potential saving, cleanup, re-initializing
func endSession():
	UIcanvas.visible = false
	background.visible = false
	activeSession.queue_free()

##TODO currently ends session, will eventually handle ending current run and starting a new one
func endRun() -> void:
	endSession()

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
		unit.logSignal.connect(managers.UImanager.toLog)
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
	var faction : Faction = factionDict[callFaction]
	var amount = enums.powerVals[size]

	var newUnit = unitScene.instantiate()
	
	newUnit.unitSize = size

	unitManager.add_child(newUnit)
	
	faction.resources = faction.resources - (amount * faction.unitCost)
	
	newUnit.maxPower = enums.powerVals[size] * faction.powerBonus
	newUnit.power = enums.powerVals[size] * faction.powerBonus
	newUnit.faction = faction.faction
	newUnit.location = faction.ownedRegions[0]
	newUnit.modulate = enums.colorDict[faction.faction]
	
	newUnit.position = faction.ownedRegions[0].position
	newUnit.name = "Unit: " + str(newUnit.ID)
	
	faction.ownedRegions[0].units.append(newUnit)
	faction.ownedUnits.append(newUnit)
	
	militaryReport()
	print("Faction: " + str(name) + " made unit" + " | " + "POW: " + str(newUnit.maxPower))

## Cleans up references to units which are removed
##TODO move to appropriate manager
func removeUnit(unit : Unit):
	unit.location.removeUnit(unit)
	factionDict[unit.faction].removeUnit(unit)
	unitDict.erase(unit.ID)

## Creates a report of relative military power of all factions
func militaryReport():
	var factions = factionManager.factionArr
	
	var highest = float(0)
	for i in factions.size():
		if factions[i].faction != 5 && factions[i].militaryPow >= highest:
			highest = factions[i].militaryPow
	
	print("Highest pow: " + str(highest))
	
	for i in factions.size():
		if factions[i].faction != 5 && highest != 0 && factions[i].militaryPow != 0:
			scoreDict[factions[i].faction] = snapped((float(factions[i].militaryPow) / float(highest)),0.01)
	
	print(str(scoreDict))

## Called by the menu for player navigation
##TODO move to appropriate manager
func _on_select_region_button_pressed() -> void:
	managers.unitManager.player.getPathRegion(regionManager.selectedRegion)
