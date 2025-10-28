extends Node

##Manager has access to game nodes
##Adds self to singleton
var UImanager
var sessionManager
var factionManager
var regionManager
var unitManager

##Manager has dictionaries that can be referenced by node ID
##regionDict[ID]
var factionDict = {}
var regionDict = {}
var unitDict = {}
var unitID : int = 0 

##Manager handles navigation
var navGraph : AStar2D = AStar2D.new()

var gameSpeed : float = 1

##Region selected in interface
var selectedRegion : Region = null

var unitScene = preload("res://prefabs/unit.tscn")

#Gets called by parent node of session once it gets it's _ready call
func initSession() -> void:
	factionManager.updateFactions()
	regionManager.updateRegions()
	unitManager.updateUnits()
	
	regionManager.parentRegions()
	
	for faction in factionManager.factionArr:
		faction.updateAdjRegions()
	
	connectGraph()

##Make add X general thing that can choose which dict to use
func addFaction(faction: Faction):
	if factionDict.has(faction):
		print("Faction already added")
	else:
		factionDict[faction.faction] = faction

func addRegion(region : Region):
	if regionDict.has(region):
		print("Faction already added")
	else:
		regionDict[region.ID] = region
		
		addToGraph(region.ID, region.graphPos)
		region.selectedRegion.connect(regionSelected)

func addUnit(unit : Unit):
	if unitDict.has(unit):
		print("Unit already added")
		return 0
	else:
		var ID = unitID
		unitDict[unitID] = unit
		
		unit.relocated.connect(unitMoved)
		
		unitID = unitID + 1
		print("new unit ID: " + str(ID))
		return ID

##When a unit arrives at a new region they send a signal which calls this function
func unitMoved(unitID : int, regionID : int, lastRegionID : int):
	var region = regionDict[regionID]
	var oldRegion = regionDict[lastRegionID]
	var unit = unitDict[unitID]
	
	var oldIndex = oldRegion.units.find(unit)
	if oldIndex != -1:
		oldRegion.units.remove_at(oldIndex)

	region.units.append(unit)
	region.notify_property_list_changed()

func tryMakeUnit(callFaction : enums.Factions, resources: int):
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
	
	faction.ownedUnits.append(newUnit)
	
	##var testRegion : Region = faction.ownedRegions[2]
	##newUnit.getPathRegion(testRegion)
	
	print("Faction: " + str(name) + " made unit" + " | " + "POW: " + str(newUnit.maxPower))

##Called by signal of regions when region is clicked
func regionSelected(ID) -> void:
	var newRegion = regionDict[ID]
	if selectedRegion != null && newRegion == selectedRegion:
			UImanager.regionSelected(null)
			selectedRegion = null
			print("Selected none")
	else:
		selectedRegion = newRegion
		UImanager.regionSelected(selectedRegion)
		print("selected: " + str(selectedRegion.ID))

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


func addToGraph(ID, graphPos) -> void:
		#ID, position, weight_scale
		navGraph.add_point(ID, graphPos, 1)

func connectGraph():
	var regionArr = regionManager.regionArr
	
	for i in regionArr.size():
		var neighbors = regionArr[i].neighbors
		if neighbors.size() > 0:
			for x in neighbors.size():
				#Connecting region to navigation graph
				navGraph.connect_points(regionArr[i].ID, neighbors[x].ID)
				#print(str(regionArr[i].ID) + " connected to: " +  str(neighbors[x].ID))
