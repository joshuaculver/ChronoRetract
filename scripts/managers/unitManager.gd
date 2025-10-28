extends Node

var unitArr : Array[Node] = []

func _ready() -> void:
	managers.unitManager = self

func updateUnits() -> void:
	unitArr = get_children()

func tick() -> void:
	for i in unitArr.size():
		unitArr[i].tick()
