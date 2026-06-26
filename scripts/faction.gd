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

##Faction will keep resources instead of building
var saving = true
##Amount to keep before spending
var saveAmt = 0

var currentGoals : Array[FactionGoal] = []
var atWar : bool = false

##Amount of income receceived most recently
var lastIncome = 0

#Dictionary for tracking relationship with other factions
@export var factionRapport : = {
	enums.Factions.RED:enums.Rapport.NEUTRAL,
	enums.Factions.BLUE:enums.Rapport.NEUTRAL,
	enums.Factions.GREEN:enums.Rapport.NEUTRAL,
	enums.Factions.YELLOW:enums.Rapport.NEUTRAL, 
	enums.Factions.PURPLE:enums.Rapport.NEUTRAL,
	enums.Factions.NONE:enums.Rapport.NEUTRAL
}

var militaryPow : int = 0

@export var resources : int = 0
##Power adjustment which regular units receive from upgrades and other effects
@export var powerBonus : float = 1.0

var incomePenalty : float = 1.0

func _ready() -> void:
	managers.addFaction(self)
	
	saveAmt = enums.powerVals[enums.UnitSize.SMALL]

func setRapport(target : enums.Factions, newRapport : enums.Rapport):
	factionRapport[target] = newRapport

func getIncome(income : int) -> void:
	var amount = income * incomePenalty
	resources = int(resources + amount)
	lastIncome = amount

func checkPenalty() -> void:
	var newPenalty = 0.0
	var totalPower = 0.0
	for unit in ownedUnits:
		newPenalty = newPenalty + enums.penaltyVals[unit.unitSize]
		totalPower = totalPower + unit.power
	newPenalty = newPenalty + (totalPower / 1000)
	if newPenalty > 0.99:
		newPenalty = 0.99
	incomePenalty = 100.0 - newPenalty

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
			checkPenalty()
		else:
			saving = false

func pursueGoal() -> void:
	if currentGoals.size() > 0:
		var goal = currentGoals[0]
		##BUILDWIDE, BUILDTALL, RAISEARMY
		match goal.goalType:
			enums.goalType.BUILDTALL:
				if goal.target != null:
					##TODO add function to find capital/most developed region
					var upgraded = false
					for stat in ownedRegions[0].statUpgrades:
						if upgraded == false:
							var check = tryUpgrade(ownedRegions[0], str(stat))
							if check:
								upgraded = true
								goal.amount = goal.amount + 1
				else:
					var upgraded = false
					for stat in goal.target.statUpgrades:
						if upgraded == false:
							var check = tryUpgrade(ownedRegions[0], str(stat))
							if check:
								upgraded = true
								goal.amount = goal.amount + 1
			enums.goalType.BUILDWIDE:
				##TODO add function to find least developed region
				var upgraded = false
				for stat in ownedRegions[0].statUpgrades:
					if upgraded == false:
						var check = tryUpgrade(ownedRegions[0], str(stat))
						if check:
							upgraded = true
							goal.amount = goal.amount + 1
			enums.goalType.RAISEARMY:
				match goal.target:
					##TODO make sure unit is created before incrementing goal
					enums.UnitSize.SMALL:
						if resources >= enums.powerVals[enums.UnitSize.SMALL]:
							managers.tryMakeUnit(faction, saveAmt, enums.UnitSize.SMALL)
							goal.amount = goal.amount + 1
					enums.UnitSize.MEDIUM:
						if resources >= enums.powerVals[enums.UnitSize.MEDIUM]:
							managers.tryMakeUnit(faction, saveAmt, enums.UnitSize.MEDIUM)
							goal.amount = goal.amount + 1
					enums.UnitSize.LARGE:
						if resources >= enums.powerVals[enums.UnitSize.LARGE]:
							managers.tryMakeUnit(faction, saveAmt, enums.UnitSize.LARGE)
							goal.amount = goal.amount + 1
					_:
						pass
			_:
				pass
	else:
		makeGoal()

func makeGoal():
	pass

func warCheck() -> void:
	var notWar = 0
	for stance in factionRapport:
		if stance == enums.Rapport.WAR:
			atWar = true
		else:
			notWar = notWar + 1
	
	if notWar == factionRapport.size():
		atWar = false

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
