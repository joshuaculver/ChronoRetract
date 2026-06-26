## Object used to give factions goals

##Needs to free() when done
class_name FactionGoal
extends Object

var goalType : enums.goalType

var amount = 0
var goalAmount

##Target if any
var target = null

func _init(type : enums.goalType, goalNum : int, targ):
	goalType = type
	goalAmount = goalNum

	if targ != null:
		target = targ

func achieved(amt : int):
	amount = amount + amt

func finish():
	if amount >= goalAmount:
		self.free()
		return true
	else:
		return false
