# Depths of Loot

![Thumbnail](/public/github%20assets/thumbnail.png)

A 2D roguelike dungeon crawler built in the Godot Engine for CSC 710: Software Engineering at the Department of Computer Science, CUNY College of Staten Island.

Developed by **Brendan Coughlan** and **Jiaxing Rong**.

---

## Overview

**Depths of Loot** is a replayable dungeon-crawling experience focused on combat, exploration, procedural generation, and rewarding player progression. Players descend into randomly generated dungeon floors, battle enemies, collect loot, and return to the marketplace to upgrade equipment before venturing deeper.

The project was developed using the **Godot Engine** and **GDScript**, with an emphasis on modular game systems and replayability.

---

## Features

- Procedurally generated dungeon floors using a **Random Walk algorithm**
- 2D combat system
- Enemy AI with chasing and attacking behaviors
- Loot and inventory systems
- Marketplace/shop system for buying and selling items
- Persistent player data between scenes
- Boss encounter with a clear end goal
- Replayable roguelike gameplay loop
- Modular game architecture for future expansion

---

## Gameplay Loop

1. Start in the marketplace
2. Enter the dungeon
3. Fight enemies and open chests
4. Collect loot and currency
5. Descend deeper or return to the surface
6. Upgrade gear in the marketplace
7. Defeat the final boss to complete the game

![Early Gameplay Loop Flow Chart](public/github%20assets/gameplayLoop.png)

---

## Technologies Used

- **Godot Engine**
- **GDScript**
- **GitHub** (version control and collaboration)
- **Aseprite** (sprite editing)
- **ChatGPT** (debugging assistance and asset generation)

---

## Installation

### Windows Executable

1. Navigate to the `builds` folder in the repository.
2. Download:
   - `Depths of Loot.exe`
3. Run the executable directly.

No additional installation is required.

> **Note:** The game currently supports only modern Windows systems with mouse and keyboard input.

---

## Controls

| Action | Key |
|---|---|
| Move | `W`, `A`, `S`, `D` |
| Attack | `Space` |
| Interact / Pick Up / Consume Item | `E` |
| Open Inventory | `B` |
| Pause Game | `Esc` |

---

## Screenshots

### Market
![Market](public/github%20assets/market.png)

### Shop
![Shop](public/github%20assets/shop.png)

### Inventory
![Inventory](public/github%20assets/inventory.png)

### Dungeon
![Dungeon](public/github%20assets/dungeon.png)

### Dungeon Combat
![Dungeon Combat](public/github%20assets/dungeonCombat.png)

### Treasure Chest Drop
![Treasure Chest Drop](public/github%20assets/treasureChestDrop.png)

### Boss Fight
![Boss Fight](public/github%20assets/bossFight.png)

---

## Dungeon Progression

Each dungeon floor increases in size and difficulty.

| Floor | Map Size | Walker Steps | Enemies | Chests |
|---|---|---|---|---|
| 1 | 90 x 90 | 1300 | 2 Normal Enemies | 4 |
| 2 | 105 x 105 | 1650 | 2 Normal + 1 Elite | 6 |
| 3 | 120 x 120 | 2000 | 3 Normal + 2 Elite | 8 |
| 4 | Boss Room | Boss Room | Boss Encounter | 0 |

The exit to the next floor remains locked until all enemies are defeated.

If the player dies, progress is reset and the game restarts from the beginning.

---

## Procedural Generation

Dungeon floors are generated using a **Random Walk algorithm**.

The generation process:
1. Creates a map filled entirely with wall tiles
2. Spawns a walker at the center
3. Randomly carves floor tiles as the walker moves
4. Places enemies and chests at valid locations

This ensures that every run feels unique.

### Example Generation Code

```gdscript
func draw_walker_generation(dimensions: Vector2i, padding: int, source_id: int, atlas_coords: Vector2i) -> void:
	var directions: Array[Vector2i] = [
		Vector2i.LEFT,
		Vector2i.RIGHT,
		Vector2i.UP,
		Vector2i.DOWN
	]

	var cur_pos: Vector2i = Vector2i(
		floor(dimensions.x / 2.0),
		floor(dimensions.y / 2.0)
	)

	var bounds: Rect2i = Rect2i(0, 0, dimensions.x, dimensions.y)

	for side in [SIDE_LEFT, SIDE_RIGHT, SIDE_TOP, SIDE_BOTTOM]:
		bounds = bounds.grow_side(side, -boundary_padding)

	for i in range(total_steps):
		if bounds.has_point(cur_pos):
			carve_floor(cur_pos, source_id, atlas_coords)

		var move_dir: Vector2i = directions.pick_random()
		var next_pos: Vector2i = cur_pos + move_dir

		if bounds.has_point(next_pos):
			cur_pos = next_pos
		else:
			directions.shuffle()
			for d in directions:
				if bounds.has_point(cur_pos + d):
					cur_pos += d
					break
```

---

## Core Systems

### Loot System

The loot system is divided into three main classes:

#### `Item`
Stores:
- Item name
- Icon
- Value
- Item-specific data

#### `LootEntry`
Stores:
- Item reference
- Drop chance
- Minimum quantity
- Maximum quantity

#### `LootTable`
Contains:
- Arrays of `LootEntry` objects
- All possible drops for enemies or chests

---

### Scene Management

Player data persistence is handled through a central game manager scene responsible for loading:
- Dungeon scenes
- Marketplace scenes
- Player scenes

This preserves:
- Player health
- Inventory
- Currency
- Equipment

### Example Scene Loader

```gdscript
func load_scene(path: String, player_position: Vector2 = Vector2(0, 0)):
	if scene_holder.get_child_count() > 0:
		scene_holder.get_child(0).queue_free()

	Game.player.position = player_position
	var scene = load(path).instantiate()
	scene_holder.add_child(scene)

	update_background_music(path)
```

---

## Development Process

The project followed a lightweight Agile workflow with weekly sprints and collaborative debugging/testing.

### Team Responsibilities

#### Brendan Coughlan
Focused on:
- Player controller
- Inventory system
- Shop system
- State machine implementation
- Core gameplay systems

#### Jiaxing Rong
Focused on:
- Procedural dungeon generation
- Dungeon customization
- Boss design
- Random event systems

Both developers collaborated on:
- Debugging
- Testing
- System integration

---

## Challenges Faced

Some of the biggest development challenges included:
- Overscoping the project early on
- Learning Godot and GDScript during development
- Managing interdependent systems
- Maintaining persistent player data across scenes
- Creating consistent art assets

Several planned systems were cut due to time constraints, including:
- Armor system
- Multiple player classes
- Reinforcement learning-based enemy AI

---

## Future Improvements

Potential future additions include:
- Expanded loot customization system
- More enemy types and attack patterns
- Ranged enemies and AoE attacks
- Status effects
- Improved visual consistency
- More dungeon floors
- Additional bosses
- Controller support
- Customizable key bindings

---
## Assets & Credits

### Game Assets

#### Treasure
https://craftpix.net/product/treasure-32x32-objects-and-icons-pixel-pack/

#### Market (Main Room)
https://craftpix.net/product/pixel-art-market-square-rpg-shop-and-npc-assets-pack/?num=1&count=31&sq=market&pos=2

#### Dungeon
https://craftpix.net/product/top-down-dungeon-pixel-tileset-for-rpg-and-roguelike-game/?num=1&count=104&sq=dungeon&pos=3

#### Player
https://craftpix.net/product/swordsman-level-4-6-pixel-character-top-down-sprite-pack/?num=2&count=67&sq=helmet&pos=12

#### Enemy
https://craftpix.net/product/top-down-pixel-skeletons-character-sprite-pack/

#### Loot
https://craftpix.net/product/demon-loot-icons-32x32-pixel-art/?num=4&count=89&sq=skeleton%20loot&pos=13

https://craftpix.net/product/loot-icons-pixel-art-pack/

https://craftpix.net/product/magic-gems-pixel-art-icons/

### Additional Tools

- **Aseprite** was used to modify and adapt sprite assets.
- **ChatGPT** was used for debugging assistance and generating some visual assets such as menu backgrounds.

---


## Course Information

**CSC 710: Software Engineering**  
Department of Computer Science  
CUNY College of Staten Island  

Professor Tianxiao Zhang  
May 2026