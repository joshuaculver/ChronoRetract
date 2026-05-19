##Unit controlled by the player
class_name Player

extends Hero

func _ready():
	##modulate = enums.colorDict[faction]
	
	##Node gets ID from manager unit dictionary
	maxPower = 500
	power = 100
	
	ID = managers.addUnit(self)
