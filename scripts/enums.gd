extends Node

##Global enum definitions
enum Factions {RED, BLUE, GREEN, YELLOW, PURPLE, NONE}
enum Rapport {SELF, ALLY, LIKE, NEUTRAL, DISLIKE, ENEMY, WAR}

enum UnitMode {AID, NEUTRAL, TRAVEL, BATTLE}
enum UnitSize {SMALL, MEDIUM, LARGE, XTRA}

##Standard power starting value for different sizes
static var powerVals = {S = 100, M = 250, L = 625, X = 1565}

const colorDict = {
	0:Color("RED"),
	1:Color("BLUE"),
	2:Color("GREEN"),
	3:Color("YELLOW"),
	4:Color("PURPLE"),
	5:Color("GRAY")
}
