extends Node

var battle = load("res://scripts/battle.gd")

var wars : Array[War] = []
var battles : Array[Battle] = []

func _ready() -> void:
	managers.battleManager = self
	
func tick():
	for war in wars:
		war.tick()
	
	for conflict in battles:
		conflict.tick()

func unitConnect(unit):
	unit.encounteredEnemy.connect(createBattle)

func createBattle(region, initiator, enemy):
	##TODO handle 3-way conflict or ensure they aren't possible
	var factions = [initiator.faction, enemy.faction]

	var newBattle = battle.new()
	var newTeam = []

	for faction in factions:
		newTeam = []
		for unit in region.units:
			if unit.faction == faction:
				newTeam.add(unit)
		
		newBattle.teams.add(newTeam)
		
	battles.append(newBattle)
