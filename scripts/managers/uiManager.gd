## Script name: uiManager
##
## Manages UI elements and menus
## This script is attached to a scene with nodes for relevant UI elements
class_name UIManager

extends Node

var mainMenuScene = preload("res://prefabs/main.tscn")

@onready var regPanel : BoxContainer = $UIcanvas/RegionControl/RegionPanel
@onready var regionButton : Button = $UIcanvas/RegionControl/RegionPanel/SelectRegionButton

## In game log readable to the player
@onready var playerLog : gameLog = $UIcanvas/PlayerLog/RichTextLabel

@onready var mainCam : Camera2D = $Camera2D

@onready var playerBar : TextureProgressBar = $UIcanvas/PlayerUIControl/PowerBar
@onready var playerActLabel : Label = $UIcanvas/PlayerUIControl/PlayerActionLabel

@onready var instanceMainMenu : mainMenu

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

func mainMenuToggle():
	if instanceMainMenu != null:
		if instanceMainMenu.visible:
			instanceMainMenu.visible = false
		else:
			instanceMainMenu.visible = true

## Updates information in the UI regarding the player unit. Gets called by a player signal when certain properties of the player unit change
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

func toLog(origin : String, message : String):
	if playerLog != null:
		playerLog.addToLog(origin, message)
