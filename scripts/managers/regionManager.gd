## Script name: regionManager.gd
##
## Manages regions and navigation between them
extends Node

var regionArr : Array[Node] = []
var regionDict = {}

## Region selected in interface
var selectedRegion : Region = null

## Navigation graph for units
var navGraph : AStar2D = AStar2D.new()

signal sendResources

##Not _init. Used by manager to initialize the region manager at appriopriate step in session initialization
func init():
	regionArr = get_children()
	for region in regionArr:
		addRegion(region)
	
	parentRegions()
	connectGraph()

func tick() -> void:
	var incomeDict = {}
	
	for i in regionArr.size():
		regionArr[i].tick()
		
		incomeDict[regionArr[i].factionOwner] = regionArr[i].resourceIncome
	
	sendResources.emit(incomeDict)

##Called by signal of regions when region is clicked
func regionSelected(ID) -> void:
	if selectedRegion != null:
		selectedRegion.selected(false)
	
	var newRegion = regionDict[ID]
	if selectedRegion != null && newRegion == selectedRegion:
			managers.UImanager.regionSelected(null)
			selectedRegion = null
			print("Selected none")
	else:
		selectedRegion = newRegion
		newRegion.selected(true)
		managers.UImanager.regionSelected(selectedRegion)
		print("selected: " + str(selectedRegion.ID))

##Adds a region to the navigate graph
func addToGraph(ID, graphPos) -> void:
		#ID, position, weight_scale
		navGraph.add_point(ID, graphPos, 1)

##Connects this regions graph position to it's neighbors
func connectGraph():
	for i in regionArr.size():
		var neighbors = regionArr[i].neighbors
		if neighbors.size() > 0:
			for x in neighbors.size():
				#Connecting region to navigation graph
				navGraph.connect_points(regionArr[i].ID, neighbors[x].ID)

##Adds this a region to be tracked by the region manager
func addRegion(region : Region):
	if regionDict.has(region):
		print("Region already added")
	else:
		regionDict[region.ID] = region
		
		addToGraph(region.ID, region.graphPos)
		region.selectedRegion.connect(regionSelected)

##Gives a region to a faction
func parentRegions() -> void:
	for i in regionArr.size():
		if regionArr[i].factionOwner != enums.Factions.NONE:
			var faction = managers.factionDict[regionArr[i].factionOwner]
			
			faction.ownedRegions.append(regionArr[i])

##Handles transferring ownership when a region is captured by a faction
func transferRegion(region : Region, oldOwner : Faction, newOwner : Faction):
	region.factionOwner = newOwner.faction
	
	if region.siegers.size() > 0:
		for unit in region.siegers:
			unit.setMode(enums.UnitMode.NEUTRAL)
	
	newOwner.ownedRegions.append(region)
	oldOwner.ownedRegions.erase(region)
	
	region.updateVisuals()
	
	oldOwner.updateAdjRegions()
	newOwner.updateAdjRegions()

##Creates a visualization of the connections on the naviation graph
func DEBUGLines():
	for i in regionArr.size():
		var neighbors = regionArr[i].neighbors
		if neighbors.size() > 0:
			for x in neighbors.size():
				var line = Line2D.new()
				line.width = 4
				line.default_color = Color.BLACK
				line.add_point(regionArr[i].position, 0)
				line.add_point(neighbors[x].position, 1)
				$"../..".add_child(line)
