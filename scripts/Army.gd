## Script name: Army.gd
##
## Class for generic units which represent faction armies

class_name Army

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
			##Regular units do not aid
			rest()
		enums.UnitMode.SIEGE:
			if location.currentDefenses <= 0.0:
				captureCheck()
	
	hasFought = false

func getDamaged(damage : int):
	power = power - damage
	if power <= 0:
		print(str(self) + " destroyed")
		die()

func die():
	destroyed.emit(self)
	queue_free()
