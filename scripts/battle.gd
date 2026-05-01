@abstract class_name Battle

extends Object

var warID : int
var ongoing : bool = true
var winner = null

##Attack/Defend referring to war sides not initiator and reactor in terms of map interaction
var atkTeam : Array[Unit] = []
var defTeam : Array[Unit] = []

func tick() -> void:
	if ongoing == true:
		if statusCheck():
			turn()
	else:
		##TODO resolve removing battle and releasing units
		pass

##Check if both sides have units, resolve outcome, etc.
func statusCheck():
	if atkTeam.size() > 0 && defTeam.size() > 0:
		return true
	else:
		if atkTeam.size() > 0:
			winner = "Attacker"
		elif defTeam.size() > 0:
			winner = "Defender"
		ongoing = false
		return false

func turn():
	print("Battle turn start")
	var atkDmg = 0
	var defDmg = 0
	
	if atkTeam.size() > 1 || defTeam.size() > 1:
		print("Complex turn")
		for unit in atkTeam:
			atkDmg += unit.power + unit.maxPower * 0.05
		for unit in defTeam:
			defDmg += unit.power + unit.maxPower * 0.05
		
		var keepGoing = true
		
		##
		while keepGoing:
			for unit in defTeam:
				if unit.power > 0:
					if atkDmg > unit.maxPower / 2:
						var actDmg = unit.maxPower / 2
						atkDmg = atkDmg - actDmg
						unit.getDamaged(actDmg)
					else:
						atkDmg = atkDmg - unit.power
						unit.getDamaged(atkDmg)
			
			if atkDmg <= 0 || atkTeam.size() <= 0:
				keepGoing = false
		
		print("Attacker turn finished")
		
		keepGoing = true
		while keepGoing:
			for unit in atkTeam:
				if unit.power > 0:
					if defDmg > unit.maxPower / 2:
						var actDmg = unit.maxPower / 2
						defDmg = defDmg - actDmg
						unit.getDamaged(actDmg)
					else:
						atkDmg = atkDmg - unit.power
						unit.getDamaged(defDmg)
			
			if defDmg <= 0 || defTeam.size() <= 0:
				keepGoing = false
		
		print("Defender turn finished")
		
	else:
		print("Simple turn")
		##TODO max power added to prevent stalling/advantage larger units. Check for balancing
		##TODO create func on units to get atk power
		atkDmg = atkTeam[0].power + (atkTeam[0].maxPower * 0.05)
		defDmg = defTeam[0].power + (defTeam[0].maxPower * 0.05)
		
		atkTeam[0].getDamaged(defDmg)
		defTeam[0].getDamaged(atkDmg)
	
	statusCheck()
	
	for unit in atkTeam:
		if unit == null || unit.power <= 0:
			atkTeam.erase(unit)

	for unit in defTeam:
		if unit == null || unit.power <= 0:
			defTeam.erase(unit)
