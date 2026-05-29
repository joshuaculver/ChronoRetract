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

var maxPower : int
var power : int :
	get:
		return power
	set(value):
		power = clamp(value, 0, maxPower)
		changed.emit()

var path : Array[int]

var hasFought : bool = false
var inBattle : bool = false

## Whether the unit will send updates on it's actions to the player log
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
signal destroyed

signal changed
signal logSignal(ID, text : String)

func _ready():
	modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	ID = managers.addUnit(self)

@abstract func tick()

@abstract func getDamaged(damage : int)

func setMode(newMode : enums.UnitMode):
	mode = newMode

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
	
func move() -> void:
	if mode == enums.UnitMode.TRAVEL || mode == enums.UnitMode.NEUTRAL:
		if path.size() > 0:
			print("moving")
			var oldID = location.ID
			var nextID = path.pop_front()
			location = managers.regionManager.regionDict[nextID]
			position = location.position
			relocated.emit(ID, location.ID, oldID)
			if logActivity:
				if path.size() == 0:
					logSignal.emit(str(ID), " Arrived at " + str(location.ID))

			hostileCheck()

func rest():
	if hasFought == false:
		if location.factionOwner == faction:
			if power < maxPower:
				power = power + (maxPower * 0.10)
		else:
			if power < maxPower:
				power = power + (maxPower * 0.025)

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
				else:
					print(str(managers.factionManager.rapportCheck(self.faction, unit.faction)))

@abstract func die()
	##destroyed.emit(self)
