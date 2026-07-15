## Script name: MainMenu.gd
##
## Node which handles general menu functions 
class_name mainMenu

extends Node

@onready var newButton = $MainMenuControl/NewGameButton
@onready var loadButton = $MainMenuControl/LoadGameButton
@onready var quitButton = $MainMenuControl/QuitGameButton

func _ready() -> void:
	managers.UImanager.instanceMainMenu = self

func _on_new_game_button_pressed() -> void:
	managers.startSession()

func exitGame() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

func _on_quit_game_button_pressed() -> void:
	exitGame()
