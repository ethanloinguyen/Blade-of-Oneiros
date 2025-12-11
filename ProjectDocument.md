# Blade of Oneiros #

## Summary ##

**Blade of Oneiros is a single-player action RPG that fuses fast, satisfying hack-and-slash combat with thoughtful, retro-inspired puzzle mechanics. Drawing influence from Illusion of Gaia, Hyperlight Drifter and early Zelda titles, the game challenges players to fluidly switch between intense battles against swarming slime enemies and clever problem-solving to unlock new pathways. As players descend deeper into the mysterious dungeon, they must master both reflexes and reasoning to survive.**

## Project Resources

([https://itch.io/](https://hadiafifah.itch.io/blade-of-oneiros))   
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1Z7eXWpFV-SrlHFVSt_nuXlzHZt53bzFxvXNTj_RhVMA/edit?usp=sharing)

## Gameplay Explanation ##

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# External Code, Ideas, and Structure #

If your project contains code that: 1) your team did not write, and 2) does not fit cleanly into a role, please document it in this section. Please include the author of the code, where to find the code, and note which scripts, folders, or other files that comprise the external contribution. Additionally, include the license for the external code that permits you to use it. You do not need to include the license for code provided by the instruction team.

If you used tutorials or other intellectual guidance to create aspects of your project, include reference to that information as well.

# Team Member Contributions

This section be repeated once for each team member. Each team member should provide their name and GitHub user information.

The general structures is 
```
Team Member 1
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.

Team Member 2
  Main Role
    Documentation for main role.
  Sub-Role
    Documentation for Sub-Role
  Other contribtions
    Documentation for contributions to the project outside of the main and sub roles.
...
```

For each team member, you shoudl work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

Add addition contributions int he Other Contributions section.
# Ethan Nguyen #

# Main Roles #


* AI and Behavior Designer: [Ben Nelson](https://github.com/bnelson1324)

## Game Logic (Jerome Hernandez) ##

## AI and Behavior Designer (Ben Nelson) ##

### Finite State Machine ###


### Basic Enemy AI ###

![](Blade-of-Oneiros/documentation/enemy%20AI%20FSM.jpg)

# Sub-Roles #

* Game Feel: [Ben Nelson](https://github.com/bnelson1324)

# Other Contributions #


## Ben Nelson ##






# Afifah Hadi #

## Animation and Visuals ##
As Animation and Visuals, I thought the best way to build up Blade of Oneiros visual style was to use open source game assets to get started, and then custom make the rest of the assets to match the style of the open source assets while also pushing it in the direction I thought would look cool.

I was able to procure character sprites, slime mob sprites, and map tilesets from CraftPix.net for free. 
Sources:
https://craftpix.net/freebies/free-swordsman-1-3-level-pixel-top-down-sprite-character-pack/ 
https://craftpix.net/freebies/free-slime-mobs-pixel-art-top-down-sprite-pack/ 
https://craftpix.net/freebies/free-2d-top-down-pixel-dungeon-asset-pack/ 
https://craftpix.net/freebies/free-pixel-art-dungeon-objects-asset-pack 

The following are my personal art contributions to this project.


### Opening and Closing Cutscenes
![](Blade-of-Oneiros/assets/projectdocument_images/closing.gif)
![](Blade-of-Oneiros/assets/projectdocument_images/opening.gif)

For this, we had a photoshoot at Jerome's place where we took reference pictures based on Alfred's screenplay. I then took those pictures, pixelized, color graded, and then drew over them to create the opening and closing cutscene. Unfortunately, during the exporting process somewhere along the line the video gets heavily compressed and is a ltitle low quality in-game.
### UI Assets

![](Blade-of-Oneiros/assets/projectdocument_images/startanim.gif)
![](Blade-of-Oneiros/assets/ui/deathscreen/youdied.png)

![](Blade-of-Oneiros/assets/ui/startbutton.png)
![](Blade-of-Oneiros/assets/ui/deathscreen/respawn.png)
![](Blade-of-Oneiros/assets/ui/deathscreen/menu.png)

### Tutorial Assets
![](Blade-of-Oneiros/assets/ui/tutorial/attacktutorial.png)
![](Blade-of-Oneiros/assets/ui/tutorial/movementtutorial.png)
![](Blade-of-Oneiros/assets/ui/tutorial/tooltip.png)
![](Blade-of-Oneiros/assets/ui/tutorial/tutorialpage.png)
![](Blade-of-Oneiros/assets/ui/tutorial/ebutton.png)

### Custom Map Assets
Although most of my contribution are original art, I also modified the open source assets (within our rights) in order to expand the utilities of the map.

![](Blade-of-Oneiros/assets/map/tileset/new_objects.png)
![](Blade-of-Oneiros/assets/projectdocument_images/Objects.gif)
### HUD Assets
<u>Boss Health Bars

![](Blade-of-Oneiros/assets/hud/bossbar_frame_1.png)
![](Blade-of-Oneiros/assets/hud/bossbar_frame_2.png)
![](Blade-of-Oneiros/assets/hud/bossbar_frame_3.png)

Player Status Bars</u>

![](Blade-of-Oneiros/assets/hud/healthbar_frame.png)
![](Blade-of-Oneiros/assets/hud/stamina_frame.png)

### Dialogue Portraits

![](Blade-of-Oneiros/assets/portraits/swordsman_lvl1.png)
![](Blade-of-Oneiros/assets/portraits/swordsman_lvl2.png)
![](Blade-of-Oneiros/assets/portraits/threeslimes.png)

The player and slime characters were simply expanded upon from the Craftpix sprites, but Old Man Smiles (below) is an NPC our team developed together. His concept is essentially "three slimes in a trench coat", and his facial features are actually the slime's eyes. Included are some concept sketches of him. 
![](Blade-of-Oneiros/assets/projectdocument_images/omssketch.jpeg)
![](Blade-of-Oneiros/assets/portraits/oldmansmiles.png)

### In-Game Sprite Assets
![](Blade-of-Oneiros/assets/mobs/3slimesontopofeachother.png)
![](Blade-of-Oneiros/assets/projectdocument_images/omsingame.png)
![](Blade-of-Oneiros/assets/projectdocument_images/projectiles.gif)

## Technical Artist ##
For this role, the line between Animation and Visuals was a bit unclear to me. We had only one animation tree, and it proved more efficient for each team member to apply the animations relevant to their own tasks. Jerome handled the player animations, Ben worked on the slimes, and Quinton set up the map. These were front-loaded tasks that needed to be completed quickly early in development, and I needed to prioritize my other responsibilities.

Instead of owning the animation tree directly, I supported my teammates by preparing assets from Craftpix in formats that were easier for them to work with. For example, Jerome needed the player sprite frames combined into a single sheet, and Quinton required the pressure plate sprites arranged with specific offsets. Whenever someone had an idea for a new feature in the game, such as Quinton’s puzzle items or Ben’s boss projectiles, I took ownership of transforming those concepts into usable assets.

## Other Contributions ##
### Build and Release Management
At the beginning of the project, I mainly used the repository to push assets, so my branch stayed a clean and up-to-date copy of main. Because of this, I often handled issues that came up in main, including rolling back accidental merges and restoring the project when conflicts occurred.

I also helped integrate code from a teammate who was having trouble with GitHub by reviewing their work and manually adding the needed changes into the repository. This helped keep our build stable and consistent throughout development.

Alongside version control, I took responsibility for exporting our game as a web playable build, and I am currently looking into options for publishing a demo on Steam if we decide to continue the project after the course.

### Background Music
I assisted Ethan in procuring and applying audio into our game, specifically the background music present in the Title Screen, Dungeon Level, Death Screen, and Boss Battle. 

Sources: 

https://opengameart.org/content/hold-line-lospec-mix 
https://opengameart.org/content/the-spanish-ninja-c64-style 
https://opengameart.org/content/haunting-chiptune-loop-void-estate 
https://opengameart.org/content/generic-8-bit-jrpg-soundtrack

### Dialogue System Contribution 
Assisted Alfred in bringing his code into repository through Git 
and implemented dialogue skip button.

