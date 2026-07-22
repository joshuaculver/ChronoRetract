## Script name: uiManager
##
## Manages UI elements and menus
## This script is attached to a scene with nodes for relevant UI elements
class_name UIManager

extends Node

var mainMenuScene = preload("res://prefabs/main.tscn")

var pauseIcon = preload("res://assets/sprites/hourglassIconPause.png")
var playIcon = preload("res://assets/sprites/hourglassIconPlay.png")

@onready var regPanel : TabContainer = $UIcanvas/RTabPanel
@onready var regionButton : Button = $UIcanvas/RTabPanel/Region/SelectRegionButton

@onready var pauseToggle : TextureButton = $UIcanvas/PauseToggle

signal playerPause

## In game log readable to the player
@onready var playerLog : gameLog = $UIcanvas/PlayerLog/RichTextLabel

@onready var mainCam : Camera2D = $Camera2D

@onready var timeDisplay : Label = $UIcanvas/TimePassed

@onready var playerBar : TextureProgressBar = $UIcanvas/PlayerUIControl/PowerBar
@onready var playerActLabel : Label = $UIcanvas/PlayerUIControl/PlayerActionLabel

@onready var instanceMainMenu : mainMenu

func _ready() -> void:
	regPanel.visible = false

## Function for selecting and deselecting a region as well as sending the region's information to the relevant menu
func regionSelected(newRegion : Region) -> void:
	if newRegion == null:
		regPanel.visible = false
		
		var titleText = regPanel.get_node("Region").get_node("Title")
		titleText.text = ""
		
		var textPanel = regPanel.get_node("Region").get_node("TextPanel/Stats")
		textPanel.text = ""
	else:
		regPanel.visible = true
		
		var titleText = regPanel.get_node("Region").get_node("Title")
		titleText.text = str(str(newRegion.ID) + " - " + newRegion.title)
		
		var textPanel = regPanel.get_node("Region").get_node("TextPanel/Stats")
		
		var infoPanel = regPanel.get_node("Region").get_node("TextPanel/Info")
		var fact = 'None'
		if managers.factionDict.has(newRegion.factionOwner):
			fact = managers.factionDict[newRegion.factionOwner]
			fact = str(fact).split(" ", false)[0]
		
		infoPanel.text = "Faction: " + "\n" + str(fact)
		
		var string = ("Population: " + str(newRegion.stats["population"]) + "\n")
		string = string  + ("Growth: " + str(newRegion.stats["growth"]) + "\n")
		string = string  + ("Production:" + str(newRegion.stats["production"]) + "\n")
		string = string  + ("Logistics:" + str(newRegion.stats["logistics"]) + "\n")
		
		textPanel.text = string

##Toggles the main menu being open or closed
func mainMenuToggle():
	if instanceMainMenu != null:
		if instanceMainMenu.visible:
			instanceMainMenu.visible = false
		else:
			instanceMainMenu.visible = true

##Updates information in the UI regarding the player unit. Gets called by a player signal when certain properties of the player unit change
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

##Adds a passed message to the player facing log
func toLog(origin : String, message : String):
	if playerLog != null:
		playerLog.addToLog(origin, message)

##Sets the player facing turn tracker to passed value
func updateTime(value : int):
	timeDisplay.text = str(value)

##Handles input for the player's pause/unpause toggle button
func _on_pause_toggle_pressed() -> void:
	playerPause.emit()
	
