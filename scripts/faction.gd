## Script name: faction.gd
##
## Class which represents factions
class_name Faction

extends Node

@export var faction : enums.Factions

var ownedRegions : Array[Region] = []
##Regions not owned by this factions adjacent to this factions regions
var adjacentRegions : Array[Region] = []
var ownedUnits : Array[Unit] = []

var unitCost : int = 100

##Regular unit power
var militaryPow : int = 0
##How bad it looks for faction compared to others
var militaryAlarm : int = 0

##Faction will keep resources instead of building
var saving = true
##Amount to keep before spending
var saveAmt = 0

#Dictionary for tracking relationship with other factions
@export var factionRapport : = {
	enums.Factions.RED:enums.Rapport.NEUTRAL,
	enums.Factions.BLUE:enums.Rapport.NEUTRAL,
	enums.Factions.GREEN:enums.Rapport.NEUTRAL,
	enums.Factions.YELLOW:enums.Rapport.NEUTRAL, 
	enums.Factions.PURPLE:enums.Rapport.NEUTRAL,
	enums.Factions.NONE:enums.Rapport.NEUTRAL
}

var resources : int = 0

func _ready() -> void:
	managers.addFaction(self)
	
	saveAmt = enums.powerVals['M']

func setRapport(target : enums.Factions, newRapport : enums.Rapport):
	factionRapport[target] = newRapport

func tick() -> void:
	if ownedUnits.size() == 0:
		saving = true
	
	var upgraded = false
	if saving == false:
		for i in ownedRegions:
			if upgraded != true:
				for x in i.statUpgrades:
					if upgraded != true:
						var check = tryUpgrade(i, str(x))
						if check == true:
							upgraded = true
							print("Upgraded: " + str(i) + "," + str(x))
	if resources >= saveAmt:
		if ownedUnits.size() == 0:
			managers.tryMakeUnit(faction, saveAmt, enums.UnitSize.SMALL)
		else:
			saving = false

##Goes down list of owned regions and buys first upgrade that can be afforded
##Returns true on succsesful upgrade
func tryUpgrade(region : Region,  stat : String):
		var price = region.upgradePrice(stat)
		if price != null && resources >= price:
			resources = resources - price
			region.upgrade(stat)
			print("Faction: " + str(name) + " upgraded: " + str(region.ID) + ", for: " + str(price))
			return true
		else:
			return false

##Checks factions military situation
func militaryCheck():
	pass

func reportScore():
	militaryPow = 0
	for i in ownedUnits.size():
		militaryPow = militaryPow + round(ownedUnits[i].maxPower / 100.0)
		
	var score : int = 0
	for region in ownedRegions:
		score = int(score + region.reportScore() + round(resources / 200.0))
	return int(score + militaryPow)

func updateAdjRegions():
	for i in ownedRegions.size():
		for x in ownedRegions[i].neighbors.size():
			if ownedRegions[i].neighbors[x].factionOwner != faction && ! adjacentRegions.has(ownedRegions[i].neighbors[x]):
				adjacentRegions.append(ownedRegions[i].neighbors[x])
	print("Faction: " + str(faction) + " | Adjacent regions: " + str(adjacentRegions))

func removeUnit(unit):
	ownedUnits.erase(unit)
