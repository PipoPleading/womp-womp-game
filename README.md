# Cracked 🥚⚔️

A multiplayer arena battler built in **Godot 4.7** where players take on the role of strategic eggs battling for survival.

## Overview

Cracked is an innovative take on the arena battler genre with a unique stealth-based predator/prey dynamic. Players control eggs equipped with advanced camouflage technology in intense free-for-all matches. The last egg standing wins.

## Gameplay

### Core Mechanics

- **Predator Cloak Camouflage**: Standing still makes your egg nearly invisible with a predator-cloak-style shader. Players are only visible by slight refraction distortions around the edges of their model.
- **Dynamic Visibility**: Movement compromises your camouflage. The more you move, the more visible you become, forcing players to balance offense with stealth.
- **Arena Battles**: Find and eliminate other players in fast-paced multiplayer combat.
- **Last Egg Standing**: Eliminate all opponents to claim victory.

### Post-Match

After being defeated, players transition into **spectator mode** where they can watch the remaining match unfold.

## Technical Details

### Built With

- **Engine**: Godot 4.7
- **Language**: GDScript
- **Physics Engine**: Jolt Physics
- **Rendering**: Forward Plus with DirectX 12 (Windows)
- **Networking**: Steam integration (AppID: 480)

### Key Features

- **Custom Refraction Shader**: Advanced `refractive.gdshader` creates the distinctive cloaking visual effect
- **Multiplayer**: Steam-integrated networking with support for up to 4 channels
- **Responsive Controls**: WASD movement, mouse attacks, jump, crouch, and pause mechanics
- **High Resolution**: Native 1920x1080 viewport with canvas item stretching

## Project Structure

```
womp-womp-game/
├── addons/                 # Godot plugins (Phantom Camera, Script IDE)
├── dev folders/            # Development assets and tools
├── game_manager.gd         # Core game logic and state management
├── refractive.gdshader     # Custom camouflage shader
├── project.godot           # Engine configuration
└── export_presets.cfg      # Build export settings
```

## Development Branches

The project uses feature branches that will be merged into `main`:

- **main** - Stable release branch
- **Nyck**, **cat-burger**, **chris**, **piperplace** - Development feature branches

## Getting Started

### Prerequisites

- **Godot 4.7** or later
- **Steam SDK** (for networking features)
- **Jolt Physics** plugin for Godot

### Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/PipoPleading/womp-womp-game.git
   ```

2. Open the project in Godot 4.7:
   - Launch Godot
   - Click "Open Project"
   - Navigate to the cloned repository
   - Select `project.godot`

3. Install dependencies:
   - Phantom Camera addon (included)
   - Script IDE addon (included)

4. Run the project:
   - Press `F5` or click the Play button in Godot

## Controls

| Input | Action |
|-------|--------|
| **WASD** | Move |
| **Space** | Jump |
| **Ctrl** | Crouch |
| **Mouse Click** | Attack |
| **ESC** | Pause |

## Contributions

Contributions are welcome! All branches besides main are fair game and will be merged in by end of day.

## Repository Info

- **Language**: GDScript
- **Status**: Active Development
- **Last Updated**: August 31, 2026
- **Repository Size**: ~102 MB
- **License**: (To be determined)

---

**Made with ❤️ using Godot Engine**

*"It's multiplayer, it's for you, it's lit."*
