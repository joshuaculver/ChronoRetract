## Script name: faction.gd
##
## Class which represents factions
class_name Faction

extends Node

@export var faction : enums.Factions
@export var displayName : String
@export var startingUnits = {
	enums.UnitSize.SMALL:0,
	enums.UnitSize.MEDIUM:0,
	enums.UnitSize.LARGE:0,
}

var ownedRegions : Array[Region] = []
##Regions not owned by this factions adjacent to this factions regions
var adjacentRegions : Array[Region] = []
var ownedUnits : Array[Unit] = []

@export var factionDisposition : enums.FactionDisposition = enums.FactionDisposition.NEUTRAL

var currentGoals : Array[FactionGoal] = []
var atWar : bool = false
var involvedWars : Array[War]

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

var militaryPow : float = 0.0
var score : float = 0.0

@export var resources : int = 0
##Power adjustment which regular units receive from upgrades and other effects
@export var powerBonus : float = 1.0

var incomePenalty : float = 1.0

func _ready() -> void:
	if faction != enums.Factions.NONE:
		managers.addFaction(self)

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
	if faction != enums.Factions.NONE:
		pursueGoal()
		commandUnits()

func pursueGoal() -> void:
	if currentGoals.size() > 0:
		var goal = currentGoals[0]
		##BUILDWIDE, BUILDTALL, RAISEARMY
		match goal.goalType:
			enums.goalType.BUILDTALL:
				if goal.target == null:
					var region = getRegion('largest')
					var upgraded = false
					for stat in region.statUpgrades:
						if upgraded == false:
							var check = tryUpgrade(region, str(stat))
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
				var region = getRegion('smallest')
				var upgraded = false
				for stat in region.statUpgrades:
					if upgraded == false:
						var check = tryUpgrade(region, str(stat))
						if check:
							upgraded = true
							goal.amount = goal.amount + 1
			enums.goalType.RAISEARMY:
				match goal.target:
					enums.UnitSize.SMALL:
						if tryMakeUnit(enums.UnitSize.SMALL):
							checkPenalty()
							goal.amount = goal.amount + 1
					enums.UnitSize.MEDIUM:
						if resources >= enums.powerVals[enums.UnitSize.MEDIUM]:
							if tryMakeUnit(enums.UnitSize.MEDIUM):
								checkPenalty()
								goal.amount = goal.amount + 1
					enums.UnitSize.LARGE:
						if resources >= enums.powerVals[enums.UnitSize.LARGE]:
							if tryMakeUnit(enums.UnitSize.LARGE):
								checkPenalty()
								goal.amount = goal.amount + 1
					_:
						pass
			enums.goalType.STARTWAR:
				managers.battleManager.createWar(managers.factionDict[faction], managers.factionDict[goal.target])
				goal.amount = goal.amount + 1
				warCheck()
			_:
				pass
		if goal.finish():
			currentGoals.erase(goal)
			goal.free()
		
	else:
		makeGoal()

func makeGoal():
	if atWar:
		var militaryScore = managers.militaryStatus[faction]
		if militaryScore < 0.5:
			var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.SMALL)
			currentGoals.append(newGoal)
		elif militaryScore < 0.75:
			var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.MEDIUM)
			currentGoals.append(newGoal)
		elif militaryScore < 0.9:
			var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.LARGE)
			currentGoals.append(newGoal)
	else:
		##Score is % of highest military power
		var militaryScore = managers.militaryStatus[faction]
		match factionDisposition:
			enums.FactionDisposition.NEUTRAL:
				if militaryScore <= 0.7:
					var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.MEDIUM)
					currentGoals.append(newGoal)
				else:
					var rand = managers.random.randf()
					if rand < 0.5:
						var newGoal = FactionGoal.new(enums.goalType.BUILDWIDE, 3, null)
						currentGoals.append(newGoal)
					else:
						var newGoal = FactionGoal.new(enums.goalType.BUILDTALL, 3, null)
						currentGoals.append(newGoal)
			enums.FactionDisposition.AGGRESIVE:
				var warTarget = warViableCheck(0.2)
				
				if warTarget != null && atWar == false:
					if ownedUnits.size() > 0:
						var newGoal = FactionGoal.new(enums.goalType.STARTWAR, 1, warTarget)
						currentGoals.append(newGoal)
				elif militaryScore <= 0.8:
					var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.LARGE)
					currentGoals.append(newGoal)
				else:
					var rand = managers.random.randf()
					if rand < 0.05:
						var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.LARGE)
						currentGoals.append(newGoal)
					if rand < 0.15:
						var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.MEDIUM)
						currentGoals.append(newGoal)
					elif rand < 0.4:
						var newGoal = FactionGoal.new(enums.goalType.BUILDWIDE, 2, null)
						currentGoals.append(newGoal)
					else:
						var newGoal = FactionGoal.new(enums.goalType.BUILDTALL, 3, null)
						currentGoals.append(newGoal)
			enums.FactionDisposition.PEACEFUL:
				if militaryScore <= 0.5:
					var newGoal = FactionGoal.new(enums.goalType.RAISEARMY, 1, enums.UnitSize.SMALL)
					currentGoals.append(newGoal)
				else:
					var rand = managers.random.randf()
					if rand < 0.6:
						var newGoal = FactionGoal.new(enums.goalType.BUILDWIDE, 3, null)
						currentGoals.append(newGoal)
					elif rand < 0.8:
						var newGoal = FactionGoal.new(enums.goalType.BUILDTALL, 2, null)
						currentGoals.append(newGoal)
			_:
				pass

func commandUnits():
	##Getting units which can be given commands
	var currentUnits = []
	for unit in ownedUnits:
		if unit != null:
			if !unit.inBattle && unit.mode == enums.UnitMode.NEUTRAL:
				currentUnits.append(unit)
	
	##Units exist which can be commanded
	if currentUnits.size() > 0:
		if atWar:
			var sieged = []
			for region in ownedRegions:
				if region.sieged:
					sieged.append(region)
			
			var unit = currentUnits.pop_front()
			while unit != null:
				if sieged.size() > 1:
					##TODO
					pass
				elif sieged.size() == 1:
					unit.getPathRegion(sieged[0])
					unit = currentUnits.pop_front()
				else:
					for war in involvedWars:
						if war.attacker == self:
							unit.getPathRegion(war.contestedRegion)
							unit = currentUnits.pop_front()
				
		else:
			##TODO spread out owned units
			for unit in currentUnits:
				pass

func getRegion(toGet: String):
	match toGet:
		'largest':
			var returnRegion = [null, 0]
			for region in ownedRegions:
				var regScore = region.reportScore()
				if score > returnRegion[1]:
					returnRegion[0] = region
					returnRegion[1] = regScore
			
			return returnRegion[0]
		'smallest':
			var returnRegion = [null, 0]
			for region in ownedRegions:
				var regScore = region.reportScore()
				if score > returnRegion[1]:
					returnRegion[0] = region
					returnRegion[1] = regScore
			
			return returnRegion[0]
		_:
			print("Region :" + str(toGet) + " requested!")
			return null

func warViableCheck(threshold : float):
	var neighbors = []
	var viable = [null, null]
	for region in adjacentRegions:
		if neighbors.has(region.factionOwner) == false:
			if region.factionOwner != enums.Factions.NONE:
				neighbors.append(region.factionOwner)
	
	var factScore = float(managers.militaryStatus[faction])
	for fact in neighbors:
		##Score will be between 0.0 and 1.0
		##Returns faction with largest score difference
		var diff = float(factScore - managers.militaryStatus[fact])
		if diff > threshold:
			if viable[0] == null || diff > viable[1]:
				viable = [fact, diff]
	
	return viable[0]

func warCheck() -> void:
	var notWar = 0
	for stance in factionRapport:
		if factionRapport[stance] == enums.Rapport.WAR:
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

func tryMakeUnit(size : enums.UnitSize):
	var cost = size
	
	if cost <= resources:
		resources = resources - cost
		managers.unitManager.createUnit(faction, size)
		return true
	else:
		return false

##Checks factions military situation
func militaryCheck():
	pass

##Returns factions which own regions adjacent to this faction
func currAdj():
	var factions = []
	for region in adjacentRegions:
		if factions.has(region.factionOwner):
			pass
		else:
			factions.append(region.factionOwner)
	
	return factions

func reportScore():
	militaryPow = 0.0
	for i in ownedUnits.size():
		militaryPow = militaryPow + ownedUnits[i].maxPower
		
	score = 0.0
	for region in ownedRegions:
		score = score + (region.reportScore() / 2.0)
		
	score = score + militaryPow
	return score

func updateAdjRegions():
	for i in ownedRegions.size():
		for x in ownedRegions[i].neighbors.size():
			if ownedRegions[i].neighbors[x].factionOwner != faction && ! adjacentRegions.has(ownedRegions[i].neighbors[x]):
				adjacentRegions.append(ownedRegions[i].neighbors[x])
	print("Faction: " + str(faction) + " | Adjacent regions: " + str(adjacentRegions))

func removeUnit(unit):
	ownedUnits.erase(unit)
