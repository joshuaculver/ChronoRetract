extends Node

var battles : Array[Battle] = []

func _ready() -> void:
	managers.battleManager = self

func tick():
	for battle in battles:
		battle.tick()

func unitConnect(unit):
	unit.encounteredEnemy.connect(createBattle)

func createBattle(region, initiator, enemy):
	##TODO handle 3-way conflict or ensure they aren't possible
	var factions = [initiator.faction, enemy.faction]

	var newBattle = Battle.new()
	var newTeam = []

	for faction in factions:
		newTeam = []
		for unit in region.units:
			if unit.faction == faction:
				newTeam.add(unit)
		
		newBattle.teams.add(newTeam)
	
	battles.append(newBattle)
