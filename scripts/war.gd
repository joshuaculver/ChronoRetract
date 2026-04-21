@abstract class_name War

extends Object

var ID : int

var attacker : Faction
var atkAllies : Array[Faction] = []

var defender : Faction
var defAllies : Array[Faction] = []

##TODO war stats for tracking purposes, penalties, etc.

func tick() -> void:
	pass
