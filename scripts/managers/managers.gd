extends Node

#TODO make manager nodes into loadable scenes to initialize and/or convert managers from Node -> Object

##Manager has access to game nodes
##Adds self to singleton

var UImanager
var sessionManager
var factionManager
var regionManager
var unitManager
var battleManager

var player

##Manager has dictionaries that can be referenced by node ID
##regionDict[ID]

##TODO move these to appropriate managers, add safe access, etc.
var factionDict = {}
var unitDict = {}
var unitID = 0

var gameSpeed : float = 1

var unitScene = preload("res://prefabs/units/army.tscn")
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
	
	##await factionManager.ready
	##await regionManager.ready
	
	regionManager.init()
	factionManager.init()
	
	unitManager.addPlayer()

##Make add X general thing that can choose which dict to use
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

##When a unit arrives at a new region they send a signal which calls this function
##This allows appropriate references to be established
func unitMoved(unitID : int, regionID : int, lastRegionID : int):
	var region = regionManager.regionDict[regionID]
	var oldRegion = regionManager.regionDict[lastRegionID]
	var unit = unitDict[unitID]
	
	var oldIndex = oldRegion.units.find(unit)
	if oldIndex != -1:
		oldRegion.units.remove_at(oldIndex)

	region.units.append(unit)
	region.notify_property_list_changed()

func tryMakeUnit(callFaction : enums.Factions, resources: int, size : enums.UnitSize):
	var faction = factionDict[callFaction]
	var amount = int(resources / faction.unitCost)

	var newUnit = unitScene.instantiate()

	unitManager.add_child(newUnit)
	
	unitManager.unitArr.append(newUnit)
	
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
	##var testRegion : Region = faction.ownedRegions[2]
	##newUnit.getPathRegion(testRegion)
	
	print("Faction: " + str(name) + " made unit" + " | " + "POW: " + str(newUnit.maxPower))

func removeUnit(unit : Unit):
	unit.location.removeUnit(unit)
	factionDict[unit.faction].removeUnit(unit)
	unitDict.erase(unit.ID)
	unitManager.unitArr.erase(unit)

	unitManager.updateUnits()


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

func _on_select_region_button_pressed() -> void:
	player.getPathRegion(regionManager.selectedRegion)
