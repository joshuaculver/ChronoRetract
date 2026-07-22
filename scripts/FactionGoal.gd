## Script name: FactionGoal.gd
##
## Object used to give factions goals

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

##Increments on faction taking an action that is part of the goal
func achieved(amt : int):
	amount = amount + amt

##Checks if the goal has been met
func finish():
	if amount >= goalAmount:
		return true
	else:
		return false
