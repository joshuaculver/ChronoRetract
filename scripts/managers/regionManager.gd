extends Node

var regionArr : Array[Node] = []

func _ready() -> void:
	managers.regionManager = self

func updateRegions() -> void:
	regionArr = get_children()

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
