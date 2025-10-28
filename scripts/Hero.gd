class_name Hero

extends Unit

func tick() -> void:
	if path.size() > 0:
		move()
		print("Hero: " + str(ID) + " arrived at: " + str(location.ID))
	else:
		if location.factionOwner == faction:
			mode = enums.UnitMode.AID
		elif  managers.factionManager.rapportCheck(faction, location.factionOwner) <= 3:
			mode = enums.UnitMode.NEUTRAL
		elif managers.factionManager.rapportCheck(faction, location.factionOwner) == 5:
			mode = enums.UnitMode.BATTLE
	if location.factionOwner == faction || managers.factionManager.rapportCheck(faction, location.factionOwner) <= 3:
		if mode == enums.UnitMode.AID || mode == enums.UnitMode.NEUTRAL:
			rest()

#TODO work in stats
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
