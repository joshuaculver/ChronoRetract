@abstract class_name Unit

extends Sprite2D

var ID : int = 0
@export var location : Region
@export var faction : enums.Factions

@export var unitSize : enums.UnitSize

##Gets assigned faction's rapport
var factionRapport : = {}

var maxPower : int = 100
var power : int = 100

var path : Array[int]

var hasFought : bool = false

##Current state of unit
@export var mode : enums.UnitMode = enums.UnitMode.NEUTRAL

signal created
signal relocated
signal encounteredEnemy(currRegion)
signal destroyed

func _ready():
	modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	ID = managers.addUnit(self)
	created.emit()

@abstract func tick()

@abstract func getDamaged(damage : int)

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
			
			if mode != enums.UnitMode.BATTLE:
				hostileCheck()

func rest():
	if hasFought == false:
		if location.factionOwner == faction:
			if power < maxPower:
				power = clamp(power + (maxPower * 0.10),0,maxPower)
		else:
			if power < maxPower:
				power = clamp(power + (maxPower * 0.025),0,maxPower)

func hostileCheck():
	for unit in location.units:
		if unit != self:
			if factionRapport[unit.factionOwner] == enums.Rapport.ENEMY:
				encounteredEnemy.emit(location, self, unit)
				##TODO set mode to battle in battleManager
				##only needs to send signal once
				break

@abstract func die()
	##destroyed.emit(self)
