extends Node

var regionArr : Array[Node] = []
var regionDict = {}

##Region selected in interface
var selectedRegion : Region = null

var navGraph : AStar2D = AStar2D.new()

##Default region setup
var regionScene = preload("res://prefabs/game/InitRegions.tscn")

func _ready():
	var newRegions = regionScene.instantiate()
	for region in newRegions.get_children():
		region.reparent(self)
		addRegion(region)
	regionArr = get_children()
	
	newRegions.queue_free()
	
func init():
	##Needs to wait for factions to be initialized or called from somewhere else
	parentRegions()
	connectGraph()

func parentRegions() -> void:
	for i in regionArr.size():
		if regionArr[i].factionOwner != enums.Factions.NONE:
			var faction = managers.factionDict[regionArr[i].factionOwner]
			
			faction.ownedRegions.append(regionArr[i])

func tick() -> void:
	for i in regionArr.size():
		regionArr[i].tick()
		if regionArr[i].factionOwner != enums.Factions.NONE:
			##Expand on this to attempt to ugprade un-owned region
			managers.factionManager.factionArr[regionArr[i].factionOwner].resources = managers.factionManager.factionArr[regionArr[i].factionOwner].resources + regionArr[i].stats["production"]

##Called by signal of regions when region is clicked
func regionSelected(ID) -> void:
	var newRegion = regionDict[ID]
	if selectedRegion != null && newRegion == selectedRegion:
			managers.UImanager.regionSelected(null)
			selectedRegion = null
			print("Selected none")
	else:
		selectedRegion = newRegion
		managers.UImanager.regionSelected(selectedRegion)
		print("selected: " + str(selectedRegion.ID))

func connectGraph():
	for i in regionArr.size():
		var neighbors = regionArr[i].neighbors
		if neighbors.size() > 0:
			for x in neighbors.size():
				#Connecting region to navigation graph
				navGraph.connect_points(regionArr[i].ID, neighbors[x].ID)
				#print(str(regionArr[i].ID) + " connected to: " +  str(neighbors[x].ID))

func addRegion(region : Region):
	if regionDict.has(region):
		print("Region already added")
	else:
		regionDict[region.ID] = region
		
		addToGraph(region.ID, region.graphPos)
		region.selectedRegion.connect(regionSelected)

func addToGraph(ID, graphPos) -> void:
		#ID, position, weight_scale
		navGraph.add_point(ID, graphPos, 1)

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
