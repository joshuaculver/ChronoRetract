## Script name: enums.gd
##
## This script is autoloaded and used to define global enums and other constant variables
extends Node

##Global enum definitions
enum Factions {RED, BLUE, GREEN, YELLOW, PURPLE, NONE}
enum Rapport {SELF, ALLY, LIKE, NEUTRAL, DISLIKE, ENEMY, WAR}

enum UnitMode {AID, NEUTRAL, TRAVEL, BATTLE}
enum UnitSize {SMALL, MEDIUM, LARGE, HERO}

##Standard power starting value for different sizes
static var powerVals = [100, 250, 625, 1565]
static var penaltyVals = [0.03, 0.05, 0.10, 0.08]

const colorDict = {
	0:Color("RED"),
	1:Color("BLUE"),
	2:Color("GREEN"),
	3:Color("YELLOW"),
	4:Color("PURPLE"),
	5:Color("GRAY")
}
