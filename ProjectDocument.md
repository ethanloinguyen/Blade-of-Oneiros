# Blade of Oneiros #

## Summary ##

**Blade of Oneiros is a single-player action RPG that fuses fast, satisfying hack-and-slash combat with thoughtful, retro-inspired puzzle mechanics. Drawing influence from Illusion of Gaia, Hyperlight Drifter and early Zelda titles, the game challenges players to fluidly switch between intense battles against swarming slime enemies and clever problem-solving to unlock new pathways. As players descend deeper into the mysterious dungeon, they must master both reflexes and reasoning to survive.**

## Project Resources

([https://itch.io/](https://hadiafifah.itch.io/blade-of-oneiros))  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  

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

## Main Roles ##

## Sub-Roles ##

## Other Contributions ##


# Jerome Hernandez #

## Main Roles ##

## Sub-Roles ##

## Other Contributions ##

# Quinton Nguyen #

## Level and World / Puzzle Design ##

### Scene Architecture & Level Structure
The  *Blade of Oneiros*  scene structure is interconnected by scene transitions build using Godot's scene-as workflow. The current state of the game is made up of three main scenes—Level1, the Boss fight, and the Debug Map. As for the implementation of the scene & level transition pipeline, it uses Godot's spawnpoint markers and Area2D triggers. The core of the pipeline is built around two core scripts 
1. **PlayerManager**, a global autoload that persists the player across scenes  
2. **LevelTransition**, an Area2D-based trigger that initiates scene changes
`PlayerManager` is responsible for guaranteeing that the player exists, is parented into the correct part of the active scene, and spawns at the correct checkpoint. The system uses:
- **SpawnPoint tags** (e.g., `"default"`, `"boss"`) to determine where the player should appear  
- A persistent `player` instance that is *never destroyed* when switching scenes  
- A deferred `change_scene_to_file()` call to ensure transitions occur cleanly within the Godot event loop  
- Automatic reassignment of runtime references, such as:
  - Registering the player with the dialogue system  
  - Reconnecting enemies to the player reference  
  - Rebuilding the enemy container so enemy spawn points reset correctly

Checkpoint data (scene path + spawn tag) is saved into `GameState`, allowing the player to be repositioned consistently even after death, respawning, or backtracking

The `LevelTransition` nodes placed inside the level are interactable “gateways” that switch scenes when the player enters them. Each transition includes:
- A configurable `target_scene`  
- A `target_spawn` tag determining the spawn location  
- Optional “press to interact” behavior using Godot’s input handling  
- Optional `single_use` functionality to disable the transition after first use  
- Integrated fade-out and fade-in effects through the `SceneTransition` system  

When triggered, each transition:
1. Plays a fade-out animation  
2. Calls `PlayerManager.change_level()` with the target scene and spawn tag  
3. After the new scene loads, plays a fade-in animation 

One singular scene of a tilemaplayer is used to control the tilemaps for all three main level scenes.
 This included:
- Defining **physics layers** for players, environment, pushables, enemies, hazards, and triggers  
- Creating a **Z-index sorting system** using Y-Sort and manual overrides  
- Designing TileMap collision shapes using Godot’s TileSet editor  
- Main tilemaplayers in each scene are contained in a Node2D container labeled Y-Sort


### **Zone Breakdown & Gameplay Purpose**

Although Level 1 is composed of two connected scenes (`lvl1` and `lvl1next`), the space is internally structured into distinct gameplay zones. Each zone is designed to introduce a specific mechanic, escalate complexity, or prepare the player for the upcoming boss fight.

---

#### **1. Tutorial / Start Area**

The opening chamber functions as a low-risk onboarding zone where players learn the core interactable systems of the game. Through tutorial papers, prompts, and simple room layout, the player is introduced to:

- Basic movement via the tutorial panel  
- Interaction prompts and tooltip UI  
- Using standard doors  
- Pushing boxes in cardinal directions  
- Breaking vases to obtain potions  

This area is intentionally uncluttered, allowing players to focus on internalizing the controls and interaction model before progressing into more complex spaces.

---

#### **2. Level 1 (Enemy Rooms, Puzzle Corridor, Breakable Tile Wing)**

Level 1 is designed as a branching sequence of combat and puzzle rooms that interlock through doors, levers, and state changes.

**Enemy Room A → Lever Path → Enemy Room B → Puzzle Areas**

- The player initially has access to **Enemy Room A**, where defeating enemies and exploring the space reveals a **lever**.  
- Activating this lever triggers audio feedback and **opens Enemy Room B**, reinforcing the idea that puzzle interactions can modify the environment at a distance.

From Enemy Room A, the exit door also leads to the **Box & Pressure Plate Puzzle** an area where the player must push boxes onto plates to open progression gates. This area teaches spatial reasoning and prepares the player for more elaborate puzzle interactions in the future.

Completing the puzzle grants access to the **Armory Room**, which serves two functions:  
1. Providing armor and a visual player upgrade  
2. Triggering the guards blocking the boss pathway to move aside  

This creates a natural mid-level reward loop.

Enemy Room B connects to the **Breakable Tiles Puzzle**, where the player must intentionally crack and destroy floor tiles.  
This area reinforces hazard awareness and introduces the risk of falling:

- Each tile must be stepped on and cracked  
- Destroying all tiles unlocks the exit  
- The **Boss Room Key** is placed here, ensuring the player must beat the puzzle to progress.

---

#### **3. Boss Arena**

The boss fight takes place in a dedicated scene structured around a central island surrounded by water. The arena layout includes:

- A **main circular fighting zone** where the boss’s attacks are easiest to read  
- A **peripheral ring-path** around the main arena, connected by narrow walkways  
- **Potion pickups** placed at the ends of the ring-path  

These surrounding paths give players the option to reposition or kite the boss, but their narrowness introduces a risk–reward trade-off. Venturing to grab healing potions can leave the player cornered or force them into dangerous movement patterns.

This arena is designed to:
- Test all movement and positioning skills learned in Level 1  
- Reward players who mastered spacing, dodging, and reading attack patterns  
- Provide a fair but high-pressure combat experience  

The design reinforces the culmination of the game’s mechanical learning curve.
### Puzzle System Implementation
#### **Pushable Boxes**
I implemented a deterministic pushable box system using `CharacterBody2D`, collision shapes, and grid snapping. Each box computes its **exact grid step size** from its `RectangleShape2D`, ensuring movement aligns perfectly with tile boundaries. Boxes snap to the grid on `_ready()` and only move in **strict cardinal directions**, enforced by a custom `DirectionSnap` helper.


#### **Pressure Plates**
Pressure plates detect any number of bodies entering their `Area2D`. These bodies include the player and also the pushable boxes.
When activated, the plate:
- Switches between two visual sprites  
- Plays activation/deactivation audio  
- Emits `activated` or `deactivated` signals  

Puzzle objects (doors and gates) subscribe to these signals
This ensures puzzle logic remains decoupled from the plate implementation and supports multi-object interactions.

#### **Levers**
Levers provide a manually triggered puzzle control system.  
Key features include:
- A cooldown timer preventing double toggles  
- Press-to-interact input handling only when the player is within a proximity `Area2D`  
- State transitions animated via `AnimationPlayer`  
- Audio feedback for on/off states  
- Emitting `activated` and `deactivated` signals  

Levers also broadcast to every node in a specified `target_group`, allowing **wide-area puzzle manipulation** (doors and gates) without hard-coded references.

#### **Breakable Tiles & Falling Cutscene**
I built the destructible floor tile system using Godot’s TileMap atlas controls and custom metadata to flag breakable tiles. When the player steps onto one of these marked tiles, the system:
- Detects the collision via the “breakable tile” layer  
- Swaps the tile for its cracked/broken variant using atlas coordinates  
- Plays a timed break animation sequence  
- Triggers the falling cutscene and forces a respawn through the PlayerManager system  

#### **Breakable Vases & Potion Spawning (Persistent Pickups)**
Breakable vases use a hit-based destruction pipeline controlled by an internal health node. Vases generally mimic the health/hitbox behavior of enemies.
The system includes:
- Hit feedback (shake tween, hit sound, frame progression)  
- Break animation and final destruction  
- Automatic potion spawning using a PackedScene instance placed using correct global transforms  

Vases also integrate with GameState persistence.  
A unique `pickup_id` is generated using the scene path and node path; once a vase is broken, it is permanently removed on future visits. This variable is also exported, so in the case we did want the vases to be respawned with the reloading of the scene, persistance is set to `false`.

### **Door Architecture (Barred, Locked, One-Use, and Persistent Doors)**
I implemented multiple door variants that all follow a unified `open()` / `close()` API:
- **Locked doors** that check the Inventory system for keys  
- **Barred/blocked doors** that require puzzle triggers  
- **Single-use doors** that cannot be closed once opened  
- **Scene-persistent doors** that remain open once unlocked via `GameState`  

Doors use:
- AnimationPlayer for open/close/idle states  
- CollisionShape enabling/disabling for physical gating  
- Area2D detection + input handling for interaction  
- Audio feedback for locked/opened states  

Variations of the doors only involve different sprites/animation players or simply different values of the exported variables of single-use, persistent, or starts-open. Each door registers a unique `door_id` so its state persists across scene reloads.



### **Tutorial Papers & Onboarding Panels**
I implemented the tutorial paper interactables placed in the early tutorial level room.  
They utilize:
- An Area2D trigger that detects player proximity  
- A looping “prompt” animation indicating that the player can interact  
- A UI tutorial panel opened via `CanvasLayer`, with page-flip audio feedback  
- An input lock to prevent interaction conflicts with cutscenes  
## Gameplay Testing ##

Gameplay testing was conducted during the class demo session as well as throughout development with several outside testers. The primary goal of these tests was to evaluate level readability, puzzle clarity, combat balance, and overall progression flow. Feedback from these sessions directly influenced revisions to puzzle layouts, player guidance systems, and boss fight tuning.

### **Key Findings & Improvements**

#### **1. Level Progression & Player Direction**
Early testers reported confusion regarding where to go next due to abrupt transitions between rooms and limited visual guidance. The lack of natural level progression resulted in:
- Accidental backtracking  
- Missing key puzzle rooms  
- Uncertainty about objective order  

**Fix Implemented:**  
To address this, we added player tooltips. However, this does not fully compensate for the poor level design.

---

#### **2. Box Pushing Sensitivity & Puzzle Softlocks**
Because pushable boxes derive their grid alignment from their **exact collision box width** rather than the TileMap’s tile size, testers frequently experienced:
- Boxes misaligning relative to pressure plates  
- Difficulty lining up pushes  
- Unintended softlocks due to boxes getting stuck or pushed incorrectly  

**Fix Implemented:**  
We added a **scene reset function** that resets the current room while preserving prior progress (e.g., doors unlocked, enemy rooms cleared). A tooltip now notifies players that this reset option exists, preventing frustration without trivializing puzzle difficulty.

---

#### **3. Boss Fight Balance**
Initial testing revealed that the boss encounter was drastically unbalanced:
- The player was always one shotted by the boss  
- The boss could be defeated in 3 hits per phase
- The low health lead to a rushed and unsatisfying fight  

**Fix Implemented:**  
We reworked the entire stat distribution for the player and boss:
- Adjusted player damage, max health
- Adjusted boss health and attack values
- Added armor + sprite upgrades in the Armory Room to reinforce progression  
- Increased potion availability throughout the dungeon and boss arena  


---

#### **4. Boss Mechanics & Engagement**
Testers noted that with the original boss design, even after stat adjustments, the fight lacked mechanical depth and felt too brief.

**Fix Implemented:**  
To improve engagement, we added:
- Additional **boss attack patterns**  
- Improved **telegraphing** to make attacks readable but challenging  
- More varied movement, increasing the need for player positioning  
- Strategic potion placement in the outer ring to create risk–reward decisions  

---

### **Overall Testing Impact**
Testing resulted in major improvements to:
- Level clarity and communication  
- Puzzle usability and prevention of softlocks  
- Combat balance and player survivability  
- Boss fight pacing and mechanical depth  

## Other Contributions ##

## Other Contributions


### Dash System Improvements (Ghost Trails, Diagonal Dash, In-Place Dash)
Beyond my primary role, I contributed to improving the game’s dash mechanic:
- Added the **ghost trail visual effect**, instancing transparent afterimages for stronger motion readability.  
- Implemented **dash-in-place behavior**, ensuring the dash triggers correctly even with minimal movement input.  
- Helped correct **diagonal dash movement**, preventing inconsistent speeds or unintended directional snapping.  

These changes improved player feedback, mobility clarity, and overall combat feel.

### Player Spawning & Checkpoint Behavior
I contributed to the design and debugging of the spawn and checkpoint pipeline. This work ensured:
- The player consistently appears at the correct `SpawnPoint` after transitioning scenes.  
- Checkpoints persist across deaths via `GameState` variables.  
- The player is smoothly repositioned without camera offsets, jittering, or misalignment.  

These fixes stabilized level progression and prevented multiple softlock conditions.

### Respawn System Integration
I assisted in refining the respawn system so that falling through breakable tiles or dying to enemies triggers a clean and predictable reset. This included:
- Ensuring the PlayerManager resets states only when necessary.  
- Reinitializing puzzle elements while preserving global progress (e.g., keys, opened doors).  
- Coordinating respawn events with camera snapping and player movement resets.  

This work improved fairness, reduced frustration, and ensured puzzle state consistency.

### **Player Camera Behavior**
I helped configure the Camera2D smoothing, offset tuning, and snap behavior. This included addressing camera jitter that occurred when the player transitioned between high and low movement speeds, and ensuring the camera behaved consistently after respawning or entering new rooms.

### **Debug Map Construction & Maintenance**
I created and maintained the Debug Map used throughout development. This map contained every major interactable (plates, boxes, levers, breakables, vases, doors) in isolation and became the team’s primary testing environment. It allowed rapid iteration on puzzle elements, collision layers, door states, and respawn behavior without requiring traversal through the entire level.

This tool significantly accelerated development and supported debugging across multiple systems.
