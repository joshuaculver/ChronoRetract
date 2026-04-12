class_name Army

extends Unit

func tick() -> void:
	hostileCheck()
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
			##Regular units do not aid
			pass
	
	hasFought = false

func die():
	pass
