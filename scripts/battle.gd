@abstract class_name Battle

extends Object

var warID : int

##Attack/Defend referring to war sides not initiator and reactor in terms of map interaction
var atkTeam : Array[Unit] = []
var defTeam : Array[Unit] = []

func tick() -> void:
	if statusCheck():
		turn()

##Check if both sides have units, resolve outcome, etc.
func statusCheck():
	return true

func turn():
	var atkDmg = 0
	var defDmg = 0
	
	if atkTeam.size() > 1 || defTeam.size() > 1:
		for unit in atkTeam:
			atkDmg += unit.power
		for unit in defTeam:
			defDmg += unit.power
			
			##Distrubute damage limited by percentage of unit max power i.e. a unit takes 25% of it's max then the next until out of damage in while loop
	else:
		##TODO max power added to prevent stalling/advantage larger units. Check for balancing
		##TODO create func on units to get atk power
		atkDmg = atkTeam[0].power + (atkTeam[0].maxPower * 0.05)
		defDmg = defTeam[0].power + (defTeam[0].maxPower * 0.05)
		
		atkTeam[0].getDamaged(defDmg)
		defTeam[0].getDamaged(atkDmg)
	
	for unit in atkTeam:
		if unit == null || unit.power <= 0:
			atkTeam.erase(unit)

	for unit in defTeam:
		if unit == null || unit.power <= 0:
			defTeam.erase(unit)
