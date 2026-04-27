extends Node

var unitArr : Array[Node] = []

var playerScene = preload("res://prefabs/units/player.tscn")

func _ready():
	pass

func addPlayer():
	var player = playerScene.instantiate()
	add_child(player)
	unitArr.append(player)
	##Arbitary region for testing
	player.location = managers.regionManager.regionArr[3]
	player.position = managers.regionManager.regionArr[3].position

func updateUnits() -> void:
	unitArr = get_children()

func tick() -> void:
	for i in unitArr.size():
		unitArr[i].tick()
