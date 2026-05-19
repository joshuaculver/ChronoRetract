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
				if location.factionOwner == faction:
					if path.size() <= 0:
						mode = enums.UnitMode.AID
				else:
					var factRapport = managers.factionManager.rapportCheck(faction, location.factionOwner)
					
					match factRapport:
						enums.Rapport.ALLY:
							if path.size() <= 0:
								mode = enums.UnitMode.AID
						enums.Rapport.LIKE:
							if path.size() <= 0:
								mode = enums.UnitMode.AID
						_:
							if path.size() <= 0:
								mode = enums.UnitMode.NEUTRAL
		enums.UnitMode.AID:
			##Region checks for aiding units
			rest()
	
	hasFought = false

##TODO work in stats
func rest():
	if hasFought == false:
		if location.factionOwner == faction:
			if power < maxPower:
				power = power + (maxPower *0.05)
				print("Resting for: " + str(maxPower *0.05) + " - Current: " + str(power))
		else:
			if power < maxPower:
				power = power + (maxPower *0.01)
				print("Resting for: " + str(maxPower *0.05) + " - Current: " + str(power))

func encUnit(other : Unit):
	if other.faction == faction:
		pass
	elif managers.factionManager.rapportCheck(faction, other.faction) == enums.Rapport.WAR:
		managers.battleManager.createBattle(location, self, other)

##Currently using army version for testing
func getDamaged(damage : int):
	power = power - damage
	if power <= 0:
		print(str(self) + " destroyed")
		die()

##Currently using army version for testing
func die():
	destroyed.emit(self)
	##TODO make sure this is handled safely and node is only removed once clean up is succesfully completed
	##queue_free()
