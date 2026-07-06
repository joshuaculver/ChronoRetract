class_name War

extends Object

var ID : int

var attacker : Faction
var atkAllies : Array[Faction] = []

var defender : Faction
var defAllies : Array[Faction] = []

var contestedRegion : Region 

func _init(attack : Faction, defend : Faction):
	attacker = attack
	defender = defend

##TODO war stats for tracking purposes, penalties, etc.
