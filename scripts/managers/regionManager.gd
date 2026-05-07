extends Node

var regionArr : Array[Node] = []
var regionDict = {}

##Region selected in interface
var selectedRegion : Region = null

var navGraph : AStar2D = AStar2D.new()

func init():
	regionArr = get_children()
	for region in regionArr:
		addRegion(region)
	
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

func connectGraph():
	for i in regionArr.size():
		var neighbors = regionArr[i].neighbors
		if neighbors.size() > 0:
			for x in neighbors.size():
				#Connecting region to navigation graph
				navGraph.connect_points(regionArr[i].ID, neighbors[x].ID)

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
