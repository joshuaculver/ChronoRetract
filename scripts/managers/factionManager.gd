extends Node

var factionArr: Array[Node] = []

#Default faction setup
var factionScene = preload("res://prefabs/game/InitFactions.tscn")

func _ready():
	var newFactions = factionScene.instantiate()
	for faction in newFactions.get_children():
		faction.reparent(self)
	factionArr = get_children()

func init():
	for faction in factionArr:
		faction.updateAdjRegions()

func rapportCheck(from : enums.Factions, to : enums.Factions):
	var rapport = %managers.factionDict.get(from).factionRapport.get(to)
	if rapport != null:
		return rapport
	else:
		return 0

func tick() -> void:
	for i in factionArr.size():
		factionArr[i].tick()
