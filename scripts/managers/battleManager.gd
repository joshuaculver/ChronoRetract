## Script name: battleManager.gd
##
## Manages wars and battles. Creates, tracks, and resolves both.
extends Node

var battle = load("res://scripts/battle.gd")

var wars = {}
var battles : Array[Battle] = []

## Advances all existing battles 
func tick():
	for conflict in battles:
		if conflict.ongoing:
			conflict.tick()
		else:
			resolveBattle(conflict)

## Connects units to their signal which calls the battle manager on encountering an enemy
func unitConnect(unit):
	unit.encounteredEnemy.connect(createBattle)

## Creates and stores a war. Units are considered enemies if they belong to factions which are at war
func createWar(attacker : Faction, defender : Faction):
	var newWar = War.new(attacker, defender)
	
	managers.factionDict[attacker.faction].setRapport(defender.faction, enums.Rapport.WAR)
	managers.factionDict[defender.faction].setRapport(attacker.faction, enums.Rapport.WAR)

	wars[newWar.ID] = newWar
	
	print("War declared: " + str(attacker) + " -> " + str(defender))

func createBattle(region : Region, caller : Unit, hostile : Unit):
	var warSelect = null
	for war in wars.values():
		if (war.attacker.faction == caller.faction || war.defender.faction == caller.faction) && (war.attacker.faction == hostile.faction || war.defender.faction == hostile.faction):
			warSelect = war
	
	if warSelect != null:
		var newBattle = battle.new()
		newBattle.warID = warSelect.ID

		for unit in region.units:
			if unit.faction == warSelect.attacker.faction:
				newBattle.atkTeam.append(unit)
				unit.setMode(enums.UnitMode.BATTLE)
			elif unit.faction == warSelect.defender.faction:
				newBattle.defTeam.append(unit)
				unit.setMode(enums.UnitMode.BATTLE)
		
		battles.append(newBattle)
		print("Battle created: " + str(newBattle.atkTeam) + " - " + str(newBattle.defTeam))
	else:
		print("Could not find war for battle call")

func resolveBattle(conflict):
	if conflict.atkTeam.size() > 0:
		for unit in conflict.atkTeam:
			if unit != null:
				unit.setMode(enums.UnitMode.NEUTRAL)

	if conflict.defTeam.size() > 0:
		for unit in conflict.defTeam:
			if unit != null:
				unit.setMode(enums.UnitMode.NEUTRAL)

	##TODO track outcome for war
	##var effectedWar = wars[conflict.warID]
	##match conflict.winnder
	
	battles.erase(conflict)
	##conflict.queue_free()
