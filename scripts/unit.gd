## Script name: unit.gd
##
## Abstract base class for all units. 

@abstract class_name Unit

extends Sprite2D

var ID : int = 0
@export var location : Region
@export var faction : enums.Factions

@export var unitSize : enums.UnitSize

##Gets assigned faction's rapport
var factionRapport : = {}

@export var maxPower : float
@export var power : float :
	get:
		return power
	set(value):
		power = clamp(value, 0, maxPower)
		changed.emit()

var path : Array[int]

var hasFought : bool = false
var inBattle : bool = false

##Whether the unit will send updates on it's actions to the player log
var logActivity : bool = false

##Current state of unit
@export var mode : enums.UnitMode = enums.UnitMode.NEUTRAL :
	get:
		return mode
	set(value):
		mode = value
		changed.emit()
		

signal relocated
signal encounteredEnemy(currRegion)
##Used in die() which is abstract
signal destroyed

signal changed
signal logSignal(ID, text : String)

func _ready():
	modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	ID = managers.addUnit(self)

##Abstract as different unit types handle their tick differently
@abstract func tick()

##Abstract as above except for taking damage
@abstract func getDamaged(damage : int)

##Function which allows the unit to handle outside requests to have it change it's mode
func setMode(newMode : enums.UnitMode):
	if newMode == enums.UnitMode.BATTLE:
		self.visible = false
	else:
		self.visible = true
	mode = newMode

##Sets the units current path to the targeted region and sets unit to travel mode causing it to move on it's ticks
func getPathRegion(target : Region) -> void:
	mode = enums.UnitMode.TRAVEL
	
	path = []
	##List comes in current position first, target position last
	if location != null && target != null:
		var newPath = managers.regionManager.navGraph.get_id_path(location.ID, target.ID)
		for i in newPath.size():
			if newPath[i] != location.ID:
				##push_back = append
				path.push_back(newPath[i])
	else:
		print("null in get path location or target")

##Handles the unit moving to a new region
func move() -> void:
	if mode == enums.UnitMode.TRAVEL || mode == enums.UnitMode.NEUTRAL:
		if path.size() > 0:
			var oldID = location.ID
			var nextID = path.pop_front()
			location = managers.regionManager.regionDict[nextID]
			position = location.position
			relocated.emit(ID, location.ID, oldID)
			if logActivity:
				if path.size() == 0:
					if self.name != null:
						logSignal.emit(str(self.name), " Arrived at " + str(location.ID))
					else:
						logSignal.emit(str(ID), " Arrived at " + str(location.ID))

			hostileCheck()

##Used by the unit to heal in neutral/friendly regions
func rest():
	if hasFought == false:
		if location.factionOwner == faction:
			if power < maxPower:
				power = power + (maxPower * 0.10)
		else:
			if power < maxPower:
				power = power + (maxPower * 0.025)

##Checks the current region for any units that the current unit is at war with due to their faction
func hostileCheck():
	print("Hostile check")
	if mode != enums.UnitMode.BATTLE:
		for unit in location.units:
			if unit != self:
				print("Other unit: " + str(unit))
				if managers.factionManager.rapportCheck(self.faction, unit.faction) == enums.Rapport.WAR:
					encounteredEnemy.emit(location, self, unit)
					print(str(self) + " found hostile " + str(unit))
					break
		
		if managers.battleManager.checkRegion(location, faction):
			mode = enums.UnitMode.SIEGE
			location.getSieged(self)

##Used by the unit to check if they've met the conditions to capture a region they are sieging 
func captureCheck():
	if managers.battleManager.checkSeized(location, managers.factionDict[faction], managers.factionDict[location.factionOwner]):
		pass

##Called when the unit is reduced to 0 power or otherwise destroyed
@abstract func die()
