extends Node

var battle = load("res://scripts/battle.gd")

var wars : Array[War] = []
var battles : Array[Battle] = []

func tick():
	for conflict in battles:
		conflict.tick()

func unitConnect(unit):
	unit.encounteredEnemy.connect(createBattle)

func createWar(attacker : Faction, defender : Faction):
	var newWar = War.new(attacker, defender)
	
	managers.factionDict[attacker.faction].setRapport(defender.faction, enums.Rapport.WAR)
	managers.factionDict[defender.faction].setRapport(attacker.faction, enums.Rapport.WAR)
	
	wars.append(newWar)
	
	print("War declared: " + str(attacker) + " -> " + str(defender))

func createBattle(region : Region, caller : Unit, hostile : Unit):
	##TODO handle 3-way conflict or ensure they aren't possible
	var warSelect = null
	for war in wars:
		if (war.attacker.faction == caller.faction || war.defender.faction == caller.faction) && (war.attacker.faction == hostile.faction || war.defender.faction == hostile.faction):
			warSelect = war
	
	if warSelect != null:
		var newBattle = battle.new()

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
