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

@onready var defVisual : Polygon2D

var ticksToChange : int = 10

var sieged : bool = false
var unitEffect : float = 0.0

@export var stats : Dictionary = {
		"population":100,
		"growth":10,
		"production":10,
		"logistics":10,
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

signal selectedRegion

func _ready():
	visual.color = enums.colorDict[factionOwner]
	statUpgrades["growth"] = stats["growth"]
	statUpgrades["production"] = stats["production"]
	statUpgrades["logistics"] = stats["logistics"]
	
	var polyShape = visual.polygon
	collider.polygon = polyShape
	outline.points = polyShape
	
	defVisual = Polygon2D.new()
	defVisual.polygon = polyShape

##For future pathfinding stuff:
##Astar2D. Can create graph of nodes. Assign regions to vector2 positions on said graph
func tick():
	##TODO add un-owned region behavior. 
	if sieged:
		pass
	else:
		if units.size() > 0:
			for i in units.size():
				if units[i].mode == enums.UnitMode.AID:
					##TODO
					unitEffect = unitEffect + (0.005 * (float(units[i].power) / 100.0))
					print("Hero: " + str(units[i].name) + " aided at: " + str(ID) + str(" current effect: ") + str(unitEffect))
		if ticksToChange > 0:
			ticksToChange -= 1
		else:
			if unitEffect > 0:
				print("Aid mult: " + str(unitEffect))
			stats["population"] = (stats["population"] + int((stats["growth"] * stats["logistics"])/2)) * (unitEffect)
			unitEffect = 0
			ticksToChange = 10
			
		##TODO add un-owned region behavior. 
		if factionOwner == enums.Factions.NONE:
			pass

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
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
	return int(stats["population"] + stats["growth"] + stats["production"] + stats["logistics"])
	
func removeUnit(unit : Unit) -> void:
	units.erase(unit)

func _on_mouse_entered() -> void:
	defVisual.color = visual.color
	visual.color = visual.color.darkened(0.4)

func _on_mouse_exited() -> void:
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
