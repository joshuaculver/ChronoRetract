class_name Unit

extends Sprite2D

var ID : int = 0
@export var location : Region
@export var faction : enums.Factions

##Gets assigned faction's rapport
var factionRapport : = {}

var maxPower : int = 100
var power : int = 100

var path : Array[int]

var hasFought : bool = false

@export var mode : enums.UnitMode = enums.UnitMode.NEUTRAL

signal created
signal relocated

func _ready():
	modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	ID = managers.addUnit(self)

#Regular unit/army version
func tick() -> void:
	if path.size() > 0:
		move()
		print("Unit: " + str(ID) + " arrived at: " + str(location.ID))
	else:
		if  location.factionOwner == faction || managers.factionManager.rapportCheck(faction, location.factionOwner) <= 3:
			mode = enums.UnitMode.NEUTRAL
		elif managers.factionManager.rapportCheck(faction, location.factionOwner) == 5:
			mode = enums.UnitMode.BATTLE
	if location.factionOwner == faction || managers.factionManager.rapportCheck(faction, location.factionOwner) <= 3:
		if mode == enums.UnitMode.NEUTRAL:
			rest()
	
	hasFought = false

##Should be player version. NPC version would get passed a target from somewhere
func getPath() -> void:
	mode = enums.UnitMode.TRAVEL
	
	var target = managers.selectedRegion
	path = []
	##List comes in current position first, target position last
	if location != null && target != null:
		var newPath = managers.navGraph.get_id_path(location.ID, target.ID)
		for i in newPath.size():
			if newPath[i] != location.ID:
				##push_back = append
				path.push_back(newPath[i])
		print("new path: " + str(newPath))
	else:
		print("null in get path location or target")

func getPathRegion(target : Region) -> void:
	mode = enums.UnitMode.TRAVEL
	
	path = []
	##List comes in current position first, target position last
	if location != null && target != null:
		##var newPath = %managers.navGraph.get_id_path(location.ID, target.ID)
		var newPath = managers.getPath(location.ID, target.ID)
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
			location = managers.regionDict[nextID]
			position = location.position
			relocated.emit(ID, location.ID, oldID)
		else:
			##Aid, battle, etc.
			mode = enums.UnitMode.NEUTRAL

func rest():
	if hasFought == false:
		if location.factionOwner == faction:
			if power < maxPower:
				power = clamp(power + (maxPower * 0.10),0,maxPower)
		else:
			if power < maxPower:
				power = clamp(power + (maxPower * 0.025),0,maxPower)

func encUnit(other : Unit):
	if factionRapport[other.factionOwner] == enums.Rapport.ENEMY:
		pass
