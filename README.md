# Chrono Retract
Godot Strategy Game Prototype. Written in GDScript.

Currently a work in progress. Code can be found in scripts

## Features

### - Turn Based
A timer dictates the speed at which a process a turn which allows events to occur such as moving, upgrading, and generating resources. These turns drive behavior from the top down allowing the managers for different game elements to control updates. Certain changes or behaviors also make use of signals to send information or update information as appropriate.
### - Regions
The game map consists of a series of regions which represent an un-directed graph of nodes. These regions track individual statistics which represent their population and logistic information. Regions can be upgraded to increase their efficiency. Regions can be owned or not owned by a faction. Each step of pathing between regions can be interrupted which allows units to change their destination at any point. 
### - Factions
Five factions which each own and benefit from regions and their output of resources. Factions use their, and other faction's, state to create goals such as creating units, upgrading their least developed region, upgrading their most developed region, and decide if and when to start wars. Using wars factions can capture regions from other factions. Factions can also create units using their resources. Each faction tracks it's overall relationship, such as ally, neutral, enemy, etc. with other factions.
### - Units
Objects which represent individuals or groups. Units use Godot's AStar2D to traverse a dynamic node graph which represents the region's connections. Units may be a member of a given faction. When in a region units effect the output of said region. Units can battle enemy units as well as siege enemy faction's regions.
### - UX
Responsive interface elements such as electing regions highlights them as well as toggles the region information panel. The player can drag and zoom the camera within a constrained area around the map. 

## Images
Early game state displaying player with the turn counter at the top, information on the lower left, game pause/resume button at the lower center, and an empty information log on the lower right.
<img width="1152" height="648" alt="ChronoRetract1" src="https://github.com/user-attachments/assets/1f9c2f9a-152f-483c-92db-f1f9fe22ad31" />

Player selecting a region, in this case region 24. The region information panel appears on the right.
<img width="1152" height="648" alt="ChronoRetract2" src="https://github.com/user-attachments/assets/446377ab-a740-43d1-b053-29744f3d2d12" />

Player having traveled to region 24. The log updates to display successfully reaching the region.
<img width="1152" height="648" alt="ChronoRetract3" src="https://github.com/user-attachments/assets/c58bcb19-f8ad-4b28-afe0-fdf36058429c" />

Pausing the game and zooming in on region 44 as the player travels to it.
<img width="1152" height="648" alt="ChronoRetract4" src="https://github.com/user-attachments/assets/17f971df-4147-4fc0-9222-4725cf30f81c" />

A unit from the red faction navigates to region 53 and sieges it. The war declaration from red to yellow is displayed in the log.
<img width="1152" height="648" alt="ChronoRetract5" src="https://github.com/user-attachments/assets/fc55ddba-a4ff-4e76-9f67-141c12a8c7bb" />

Having captured the neighboring yellow region the faction represented by red declares war on the green faction as it is weaker.
<img width="1152" height="648" alt="ChronoRetract6" src="https://github.com/user-attachments/assets/6d2c8a7e-3ec9-45c9-9d5a-9f2caa8d0150" />
