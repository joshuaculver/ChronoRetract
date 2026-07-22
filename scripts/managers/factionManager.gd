## Script name: factionManager.gd
##
## Stores and manages factions
extends Node

var factionArr: Array[Node] = []
var factionDict: Dictionary = {}

func init():
	factionArr = get_children()
	for faction in factionArr:
		faction.updateAdjRegions()

func tick() -> void:
	for i in factionArr.size():
		factionArr[i].tick()

##Returns the rapport the first passed faction has towards the second
func rapportCheck(from : enums.Factions, to : enums.Factions):
	var rapport = managers.factionDict.get(from).factionRapport.get(to)
	if rapport != null:
		return rapport
	else:
		return 0

##Gives each faction it's resource income
func dispenseIncome(income : Dictionary):
	factionDict = managers.factionDict
	var dictEntries = income.keys()
	
	for key in dictEntries:
		if key != enums.Factions.NONE && factionDict[key] != null:
			factionDict[key].resources = factionDict[key].resources + income[key]
