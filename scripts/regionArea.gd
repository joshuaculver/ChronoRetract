## Script name: regionArea.gd
##
## Class which represents individual regions which make up the map

class_name Region

extends Area2D

@export var ID : int
@export var title : String

@export var factionOwner : enums.Factions

@export var neighbors : Array[Region] = []
@export var units : Array[Unit] = []

@export var graphPos : Vector2

@onready var visual: Polygon2D = $Polygon2D
@onready var collider : CollisionPolygon2D = $CollisionPolygon2D
@onready var outline : Line2D = $Line2D
@onready var regionControl : Control = $Control

@onready var defVisual : Polygon2D

##Defines how many ticks pass before the region produces resources
var ticksToChange : int = enums.baseTicksToChange

var sieged : bool = false
var currentDefenses = 750
var unitEffect : float = 0.0

var resourceIncome : int = 0

##Rough representation of region development
var score : float = 0.0

@export var stats : Dictionary = {
		"population":100,
		"growth":10,
		"production":10,
		"logistics":10,
		"defenses":750
	}

@export var statUpgrades : Dictionary = {
		"growth":1,
		"production":1,
		"logistics":1,
}

var upgradePriceMult : Dictionary = {
	"growth":3.2,
	"production":2.5,
	"logistics":1.7,
}

##TODO 
var derivedStats : Dictionary = {
	"travelTime":30
}

signal selectedRegion

func _ready():
	visual.color = enums.colorDict[factionOwner]
	
	var polyShape = visual.polygon
	collider.polygon = polyShape
	outline.points = polyShape
	
	defVisual = Polygon2D.new()
	defVisual.polygon = polyShape
	
	if title != null && title != '':
		regionControl.set_tooltip_text(title)
	else:
		regionControl.set_tooltip_text(str(ID))
		
	stats.get_or_add("defenses", 750)

func tick():
	if sieged:
		print(str(ID) + " - " + str(title) + " : is being sieged! Defenses remaining: " + str(stats["defenses"]))
	else:
		if factionOwner == enums.Factions.NONE:
			##TODO un-owned region behavior
			pass
		else:
			##Repair defenses if damaged
			if currentDefenses < stats["defenses"]:
				currentDefenses = currentDefenses + (stats["defenses"] * 0.1)
			elif currentDefenses > stats["defenses"]:
				currentDefenses = stats["defenses"]
			
			if units.size() > 0:
				for i in units.size():
					if units[i].mode == enums.UnitMode.AID:
						##TODO move to hero function
						unitEffect = unitEffect + (0.005 * (float(units[i].power) / 100.0))
						print("Hero: " + str(units[i].name) + " aided at: " + str(ID) + str(" current effect: ") + str(unitEffect))
			if ticksToChange > 0:
				ticksToChange -= 1
			else:
				if unitEffect > 0:
					print("Aid mult: " + str(unitEffect))
				stats["population"] = (stats["population"] + int((stats["growth"] * stats["logistics"])/2)) * (unitEffect)
				unitEffect = 0
				ticksToChange = enums.baseTicksToChange
			
				var mult = ((stats["population"] / 200.0) + (stats["logistics"] / 15.0))
				if mult <= 0.0:
					mult = 0.01
			
				resourceIncome = int(stats["production"] * mult)

func calcDerived() -> void:
	var newTime = int(((100.0 - stats["logistics"]) / 3.0) * 1.5)
	
	if newTime >= 1:
		derivedStats["travelTime"] = newTime
	else:
		derivedStats["travelTime"] = 1

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if managers.menuLock == false:
		if event.is_action("select"):
			if event.is_pressed():
				selectedRegion.emit(ID)

func upgrade(stat : String):
	statUpgrades[stat] = statUpgrades[stat] + 1
	stats[stat] = stats[stat] + 1

func upgradePrice(stat : String):
	for entry in statUpgrades:
		if entry == stat:
			var cost = (statUpgrades[entry]) * (10 * upgradePriceMult[entry]) * upgradePriceMult[entry]
			statUpgrades[entry] = statUpgrades[entry] + 1
			return cost
	##Iterated all stat upgrades and didn't find match for stat
	return null

func reportScore():
	var currScore = float(stats["population"] + stats["growth"] + stats["production"] + stats["logistics"]) * 5.0
	score = currScore
	return currScore

##Returns the key for the requested stat. Otherwise will return null
func getStat(toGet : String):
	match toGet:
		'highest':
			var highest = [null, 0]
			for stat in stats.keys():
				if stats[stat] > highest[1]:
					highest = [stat, stats[stat]]
				
			return highest[0]
		'lowest':
			var lowest = [null, 0]
			for stat in stats.keys():
				if stats[stat] < lowest[1]:
					lowest = [stat, stats[stat]]
				
			return lowest[0]
		_:
			print("stat: " + str(toGet) + " was requested!")
			return null
	
func removeUnit(unit : Unit) -> void:
	units.erase(unit)

func _on_mouse_entered() -> void:
	if managers.menuLock == false:
		defVisual.color = visual.color
		visual.color = visual.color.darkened(0.4)

func _on_mouse_exited() -> void:
	if managers.menuLock == false:
		visual.color = defVisual.color
	
func selected(input : bool):
	if input:
		z_index = 1
		outline.default_color = Color.WHITE
		outline.width = 4.0
	else:
		z_index = 0
		outline.default_color = Color.BLACK
		outline.width = 2.0
