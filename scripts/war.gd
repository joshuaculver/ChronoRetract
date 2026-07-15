## Script name: war.gd
##
## Object class used to represent and track wars between factions
class_name War

extends Object

var ID : int

var attacker : Faction
var atkAllies : Array[Faction] = []

var defender : Faction
var defAllies : Array[Faction] = []

var contestedRegion : Region
var contestedSeized : bool = false

var victoryPoints = 0.0
var length = 0.0

var resolve : bool = false
var attackerWins : bool = false

func _init(attack : Faction, defend : Faction):
	attacker = attack
	defender = defend

func tick():
	if victoryPoints > 10.0:
		attackerWins = true
		resolve = true
	if length > 49.0:
		attackerWins = false
		resolve = true

	length = length + 1.0

	if contestedSeized:
		victoryPoints = victoryPoints + 1.0

##TODO war stats for tracking purposes, penalties, etc.
