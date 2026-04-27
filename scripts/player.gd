##Unit controlled by the player
class_name Player

extends Hero

func _ready():
	##modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	ID = managers.addUnit(self)
	created.emit()
	
	##DEBUG
	managers.player = self
