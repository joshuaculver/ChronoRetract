class_name mainMenu

extends Node

@onready var newButton = $MainMenuControl/NewGameButton
@onready var loadButton = $MainMenuControl/LoadGameButton

func _ready() -> void:
	managers.UImanager.instanceMainMenu = self

func _on_new_game_button_pressed() -> void:
	managers.startSession()
