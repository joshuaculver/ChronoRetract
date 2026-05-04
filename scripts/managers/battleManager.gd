extends Node

var battle = load("res://scripts/battle.gd")

##var wars : Array[War] = []
var wars = {}
var battles : Array[Battle] = []

func tick():
	for conflict in battles:
		if conflict.ongoing:
			conflict.tick()
		else:
			resolveBattle(conflict)

func unitConnect(unit):
	unit.encounteredEnemy.connect(createBattle)

func createWar(attacker : Faction, defender : Faction):
	var newWar = War.new(attacker, defender)
	
	managers.factionDict[attacker.faction].setRapport(defender.faction, enums.Rapport.WAR)
	managers.factionDict[defender.faction].setRapport(attacker.faction, enums.Rapport.WAR)

	##wars.append(newWar)
	wars[newWar.ID] = newWar
	
	print("War declared: " + str(attacker) + " -> " + str(defender))

func createBattle(region : Region, caller : Unit, hostile : Unit):
	var warSelect = null
	for war in wars.array():
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
	if conflict.attacker != null:
		conflict.attacker.setMode(enums.UnitMode.NEUTRAL) 
	if conflict.atkAllies.size() > 0:
		for unit in conflict.atkAllies:
			if unit != null:
				unit.setMode(enums.UnitMode.NEUTRAL)
	
	if conflict.defender != null:
		conflict.defender.setMode(enums.UnitMode.NEUTRAL) 
	if conflict.defAllies.size() > 0:
		for unit in conflict.defAllies:
			if unit != null:
				unit.setMode(enums.UnitMode.NEUTRAL)

	##TODO track outcome for war
	##var effectedWar = wars[conflict.warID]
	##match conflict.winnder
	
	battles.erase(conflict)
	conflict.queue_free()
	
