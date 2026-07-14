## Script name: battleManager.gd
##
## Manages wars and battles. Creates, tracks, and resolves both.
extends Node

var battle = preload("res://prefabs/battle.tscn")

var wars = {}
var battles : Array[Battle] = []

var warID = 1

signal logSignal(ID, text : String)

## Advances all existing battles 
func tick():
	for conflict in battles:
		if conflict.ongoing:
			conflict.tick()
		else:
			resolveBattle(conflict)
	if wars.size() > 0:
		for war in wars:
			wars[war].tick()
			if wars[war].resolve:
				resolveWar(wars[war])

## Connects units to their signal which calls the battle manager on encountering an enemy
func unitConnect(unit):
	unit.encounteredEnemy.connect(createBattle)

## Creates and stores a war. Units are considered enemies if they belong to factions which are at war
func createWar(attacker : Faction, defender : Faction):
	var newWar = War.new(attacker, defender)
	
	managers.factionDict[attacker.faction].setRapport(defender.faction, enums.Rapport.WAR)
	managers.factionDict[attacker.faction].warCheck()
	managers.factionDict[defender.faction].setRapport(attacker.faction, enums.Rapport.WAR)
	managers.factionDict[defender.faction].warCheck()
	
	var goals = []
	var target
	for region in attacker.adjacentRegions:
		if region.factionOwner == defender.faction:
			goals.append(region)
	
	##TODO currently randomly picks valid regions to attack
	if goals.size() > 1:
		target = goals[managers.random.randi_range(0,(goals.size()-1))]
	elif goals.size() == 1:
		target = goals[0]
	else:
		target = null

	newWar.contestedRegion = target
	
	while wars.has(warID):
		warID = warID + 1
	
	newWar.ID = warID
	wars[newWar.ID] = newWar
	
	attacker.involvedWars.append(newWar)
	defender.involvedWars.append(newWar)
	
	logSignal.emit(str(attacker.faction), " Has declared war on: " + str(defender.faction))
	print("War declared: " + str(attacker) + " -> " + str(defender))

func createBattle(region : Region, caller : Unit, hostile : Unit):
	var warSelect = null
	for war in wars.values():
		if (war.attacker.faction == caller.faction || war.defender.faction == caller.faction) && (war.attacker.faction == hostile.faction || war.defender.faction == hostile.faction):
			warSelect = war
	
	if warSelect != null:
		var newBattle = battle.instantiate()
		add_child(newBattle)
		newBattle.warID = warSelect.ID

		for unit in region.units:
			if unit.faction == warSelect.attacker.faction:
				newBattle.atkTeam.append(unit)
				unit.setMode(enums.UnitMode.BATTLE)
			elif unit.faction == warSelect.defender.faction:
				newBattle.defTeam.append(unit)
				unit.setMode(enums.UnitMode.BATTLE)

		
		newBattle.initIcon()
		battles.append(newBattle)
		print("Battle created: " + str(newBattle.atkTeam) + " - " + str(newBattle.defTeam))
	else:
		print("Could not find war for battle call")

##Called by units to check if region is being targeted for siege by given faction
func checkRegion(region : Region, faction : enums.Factions):
	var checkFaction = managers.factionDict[faction]
	for war in wars:
		##TODO or ally
		if wars[war].attacker == checkFaction:
			if wars[war].contestedRegion == region:
				return true
	
	return false

func checkSeized(region : Region, attacker : Faction, defender : Faction):
	if region.currentDefenses <= 0:
		for war in wars:
			if wars[war].attacker == attacker && wars[war].defender == defender:
				wars[war].contestedSeized = true
				return true
	else:
		return false

func resolveBattle(conflict):
	if conflict.atkTeam.size() > 0:
		for unit in conflict.atkTeam:
			if unit != null:
				unit.setMode(enums.UnitMode.NEUTRAL)

	if conflict.defTeam.size() > 0:
		for unit in conflict.defTeam:
			if unit != null:
				unit.setMode(enums.UnitMode.NEUTRAL)
	
	battles.erase(conflict)
	conflict.queue_free()

func resolveWar(war):
	if war.attackerWins:
		managers.regionManager.transferRegion(war.contestedRegion, war.defender, war.attacker)
	
	war.attacker.warCheck()
	war.defender.warCheck()
	
	wars.erase(war.ID)
