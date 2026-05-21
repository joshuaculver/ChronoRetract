class_name UIManager
## Script name: uiManager
##
## Manages UI elements and menus
## This script is attached to a scene with nodes for relevant UI elements

extends Node

@onready var regPanel : BoxContainer = $CanvasLayer/RegionControl/RegionPanel
@onready var regionButton : Button = $CanvasLayer/RegionControl/RegionPanel/SelectRegionButton

@onready var mainCam : Camera2D = $Camera2D

@onready var playerBar : TextureProgressBar = $CanvasLayer/PlayerUIControl/PowerBar
@onready var playerActLabel : Label = $CanvasLayer/PlayerUIControl/PlayerActionLabel

## Function for selecting and deselecting a region as well as sending the region's information to the relevant menu
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
		titleText.text = str(str(newRegion.ID) + " - " + newRegion.title)
		
		var textPanel = regPanel.get_node("TextPanel/Stats")
		
		var string = ("Population: " + str(newRegion.stats["population"]) + "\n")
		string = string  + ("Growth: " + str(newRegion.stats["growth"]) + "\n")
		string = string  + ("Production:" + str(newRegion.stats["production"]) + "\n")
		string = string  + ("Logistics:" + str(newRegion.stats["logistics"]) + "\n")
		
		textPanel.text = string

## Updates information in the UI regarding the player unit. Gets called by a player signal whenever the player unit's properties change
func playerUpdate():
	if managers.unitManager.player.power != 0:
		var percent = (float(managers.unitManager.player.power) / float(managers.unitManager.player.maxPower)) * 100.0
		playerBar.value = percent

	match managers.unitManager.player.mode:
		enums.UnitMode.NEUTRAL:
			if managers.unitManager.player.power < managers.unitManager.player.maxPower:
				playerActLabel.text = "Resting"
			else:
				playerActLabel.text = "Waiting..."
		enums.UnitMode.TRAVEL:
			playerActLabel.text = "Traveling"
		enums.UnitMode.BATTLE:
			playerActLabel.text = "Battling"
		enums.UnitMode.AID:
			playerActLabel.text = "Aiding Region"
		_:
			playerActLabel.text = ""
