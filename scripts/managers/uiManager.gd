extends Node

@onready var regPanel : BoxContainer = $RegionPanel

func _ready() -> void:
	managers.UImanager = self

func regionSelected(newRegion : Region) -> void:
	if newRegion == null:
		regPanel.visible = false
		
		var titleText = regPanel.get_node("Title")
		titleText.text = ""
		
		var textPanel = regPanel.get_node("TextPanel/Stats")
		textPanel.text = ""
	else:
		regPanel.visible = true
		
		var titleText = regPanel.get_node("Title")
		titleText.text = str(newRegion.ID)
		
		var textPanel = regPanel.get_node("TextPanel/Stats")
		
		var string = ("Population: " + str(newRegion.stats["population"]) + "\n")
		string = string  + ("Growth: " + str(newRegion.stats["growth"]) + "\n")
		string = string  + ("Production:" + str(newRegion.stats["production"]) + "\n")
		string = string  + ("Logistics:" + str(newRegion.stats["logistics"]) + "\n")
		
		textPanel.text = string
