##Unique unit type
class_name Hero

extends Unit

func tick() -> void:
	match mode:
		enums.UnitMode.NEUTRAL:
			rest()
		enums.UnitMode.BATTLE:
			##TODO
			pass
		enums.UnitMode.TRAVEL:
			if path.size() > 0:
				move()
				print("Unit: " + str(ID) + " arrived at: " + str(location.ID))
			else:
				##Faction rapport is an indexed enum 
				if location.factionOwner == faction || managers.factionManager.rapportCheck(faction, location.factionOwner) <= 2:
					if path.size() <= 0:
						mode = enums.UnitMode.AID
				elif managers.factionManager.rapportCheck(faction, location.factionOwner) <= 3:
					if path.size() <= 0:
						mode = enums.UnitMode.NEUTRAL
				elif managers.factionManager.rapportCheck(faction, location.factionOwner) == 5:
					if path.size() <= 0:
						mode = enums.UnitMode.BATTLE
		enums.UnitMode.AID:
			##TODO
			pass
	
	hasFought = false

##TODO work in stats
func rest():
	if hasFought == false:
		if location.factionOwner == faction:
			if power < maxPower:
				power = clamp(power + (maxPower *0.15),0,maxPower)
		else:
			if power < maxPower:
				power = clamp(power + (maxPower *0.05),0,maxPower)

func encUnit(other : Unit):
	if other.faction == faction:
		pass
	elif factionRapport[other.factionOwner] == enums.Rapport.ENEMY:
		pass

func getDamaged(damage : int):
	pass

func die():
	pass
