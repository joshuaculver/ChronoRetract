## Script name: enums.gd
##
## This script is autoloaded and used to define global enums and other constant variables
extends Node

##Global enum definitions

##Used to consistently reference each faction
enum Factions {RED, BLUE, GREEN, YELLOW, PURPLE, NONE}
##How a faction can perceive any other faction
enum Rapport {SELF, ALLY, LIKE, NEUTRAL, DISLIKE, ENEMY, WAR}

##Determines how likely factions are to pursue different goals
enum FactionDisposition {AGGRESIVE, NEUTRAL, PEACEFUL}

##Determines what if anything a unit does
enum UnitMode {AID, NEUTRAL, TRAVEL, BATTLE, SIEGE}
##Abstractly represents both armies and heroes of increasing size and strength
enum UnitSize {SMALL, MEDIUM, LARGE, HERO}

##How many ticks it takes for a region to take a "turn" causing it to generate resources among other things
static var baseTicksToChange : int = 15

##Standard power starting value for different sizes
static var powerVals = [100, 250, 625, 1565]
##How much of an income penalty each size of unit incurs to it's owning faction
static var penaltyVals = [0.03, 0.05, 0.10, 0.08]

##Actions which factions can plan and then carry out
enum goalType {BUILDWIDE, BUILDTALL, RAISEARMY, STARTWAR}

##Used for consistent color across factions
const colorDict = {
	0:Color("RED"),
	1:Color("BLUE"),
	2:Color("GREEN"),
	3:Color("YELLOW"),
	4:Color("PURPLE"),
	5:Color("GRAY")
}
