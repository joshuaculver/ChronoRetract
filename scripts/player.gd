## Script name: player.gd
##
## The class for the unit which the player controls
class_name Player

extends Hero

signal playerDefeated

func _ready():
	##modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	ID = managers.addUnit(self)
	logActivity = true
	
	managers.UImanager.playerUpdate()

func die() -> void:
	emit_signal('playerDefeated')
