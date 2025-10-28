extends Node

var factionArr: Array[Node] = []

func _ready() -> void:
	managers.factionManager = self

func updateFactions() -> void:
	factionArr = get_children()

func rapportCheck(from : enums.Factions, to : enums.Factions):
	var rapport= managers.factionDict.get(from).factionRapport.get(to)
	if rapport != null:
		return rapport
	else:
		return 0

func tick() -> void:
	for i in factionArr.size():
		factionArr[i].tick()
