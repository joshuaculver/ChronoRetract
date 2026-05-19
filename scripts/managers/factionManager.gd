extends Node
## Script name: factionManager.gd
##
##

var factionArr: Array[Node] = []

func init():
	factionArr = get_children()
	for faction in factionArr:
		faction.updateAdjRegions()

func rapportCheck(from : enums.Factions, to : enums.Factions):
	var rapport = managers.factionDict.get(from).factionRapport.get(to)
	if rapport != null:
		return rapport
	else:
		return 0

func tick() -> void:
	for i in factionArr.size():
		factionArr[i].tick()
