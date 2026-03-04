# Chrono Retract
Godot Strategy Game Prototype. Written in GDScript.

Currently a work in progress. Code can be found in scripts

## Features
### - Turn Based
A timer dictates the speed at which a process a turn which allows events to occur such as moving, upgrading, and generating resources.
### - Regions
The game map consists of a series of regions which represent an undirected graph of nodes. These regions track individual statistics which represent their population and logistic information. Regions can be upgraded to increase their efficiency. Regions can be owned or not owned by a faction. Clicking on a region will display information about it as well as a button which causes the player unit to path towards it. Pathing can be interrupted and the unit arrives and stays at each node as it moves. 
### - Factions
Five factions which each own and benefit from regions and their output of resources. Factions can also create units using their resources. Each faction tracks it's overall relationship, such as ally, neutral, enemy, etc. with other factions.
### - Units
Objects which represent individuals or groups. These objects can traverse the region nodes and pathfind from their current position to any other region which a valid path exists to. Units may be a member of a given faction. When in a region units effect the output of said region.

## Planned Features
- Speed settings (Faster turns, slower turns, pause turns.) 
- Combat between units.
- Faction preferences for choosing between improvements, units, and etc.
- Player character progression
- Repeating time loop structure

## Images (all visuals are currently place holders)
Current factions resources on the left. The icon represents the player.
<img width="1150" height="648" alt="CRexample1" src="https://github.com/user-attachments/assets/f736e4e2-c423-44a1-8bc5-76defea734ba" />

Player has moved to a blue faction region. The red and yellow factions have created units. Region 15 has been selected with the mouse displaying information about it on the right (as well as some place holder text).
<img width="1150" height="648" alt="CRexample2" src="https://github.com/user-attachments/assets/ea7e74be-7018-4b9b-a201-40599e4301ba" />