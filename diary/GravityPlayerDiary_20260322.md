# Gravity Player — Dev Diary
**Date:** 2026-03-22
**Engine:** Godot 4.6 (Forward Plus)
**Project name in Godot:** `GravityPlayer`

---

## What Was Built Today (Starting From Zero)

### Project Setup
- Created a Godot 4.6 project called **GravityPlayer**.
- Physics engine set to **Jolt Physics**.
- TAA anti-aliasing enabled.
- D3D12 rendering driver on Windows.
- Added a `.gitignore` (standard Godot 4 one — ignores `.godot/`, `.import/`, `.mono/`, etc.) and `.gitattributes` (LF normalization).
- Added `.editorconfig` (UTF-8 charset).

---

### Input Map (`project.godot`)
Defined the following input actions:

| Action | Keyboard | Gamepad |
|---|---|---|
| `MoveForward` | W | Left stick up |
| `MoveBackward` | S | Left stick down |
| `MoveLeft` | A | Left stick left |
| `MoveRight` | D | Left stick right |
| `LookUp` | — | Right stick up |
| `LookDown` | — | Right stick down |
| `LookLeft` | — | Right stick left |
| `LookRight` | — | Right stick right |

---

### Player Scene (`player_tpc_gravity.tscn`)
Located at: `game/player/player_tpc_gravity.tscn`

**Scene tree:**
```
player_root  [RigidBody3D]  ← has player_tpc_gravity.gd
├── CollisionShape3D         ← CapsuleShape3D
├── MeshInstance3D           ← CapsuleMesh (visual)
└── CamPivotManager  [Node3D]  ← has cam_pivot_manager.gd
    └── CamPivot_RotateLeftRight  [Node3D]
        └── CamPivot_RotateUpDown  [Node3D]
            └── Camera3D
```

**Key settings on `player_root` (RigidBody3D):**
- All angular axes locked (X, Y, Z) so the capsule doesn't tip over.
- `PhysicsMaterial` with `friction = 0.2`, `rough = true`.
- `linear_damp = 2.0` set in code (acts as ground friction).

**Camera:**
- FOV: 90°
- Positioned behind and slightly above the player (third-person style).
- Offset approx: `(-0.857, 1.135, -1.628)` from the pivot.

---

### Player Movement Script (`player_tpc_gravity.gd`)
Located at: `game/player/player_tpc_gravity_scripts/player_tpc_gravity.gd`

**How it works:**
- Extends `RigidBody3D`.
- Gets a reference to `CamPivot_RotateLeftRight` on `_ready()`.
- Every `_physics_process()` tick:
  1. Reads WASD input into a `Vector3` (`input_direction`).
  2. Gets the camera pivot's **forward** and **right** vectors from `CamPivot_LR.global_transform.basis`.
  3. Flattens `pivot_forward.y = 0` so movement stays on the ground plane regardless of camera angle.
  4. Combines forward/right into a `move_direction` and normalizes it.
  5. Calls `apply_central_force(move_direction * movement_force)` — continuous force approach (not impulse), balanced by `linear_damp`.

**Variables:**
- `movement_speed: float = 1.0` (not yet wired up — reserved)
- `movement_force: float = 30.0`
- `linear_damp: float = 2.0` (set in `_ready`)

---

### Camera Script (`cam_pivot_manager.gd`)
Located at: `game/player/player_tpc_gravity_scripts/cam_pivot_manager.gd`

**How it works:**
- Extends `Node3D`.
- On `_ready()`: captures the mouse (`MOUSE_MODE_CAPTURED`).
- `_input()`:
  - `Escape` toggles mouse capture on/off.
  - On `InputEventMouseMotion`: reads `event.screen_relative * mouse_sensitivity` and calls `camera_look()`.
- `camera_look(mouse_movement)`:
  - Accumulates mouse delta into `camera_rotation: Vector2`.
  - Resets `transform.basis = Basis()` then re-applies rotation via `rotate_object_local` — this drives both left/right and up/down look.
  - Clamps vertical rotation to `±1.2` radians (~69°).
  - **Gamepad** look is mapped in the input map but not yet implemented in script.

**Variables:**
- `mouse_sensitivity: float = 0.001`
- `max_y_rotation: float = 1.2`

---

### Test Level (`level_player_test.tscn`)
Located at: `game/player/levels/level_player_test.tscn`
This is the **main scene** set in `project.godot`.

**What's in the level:**
- A `DirectionalLight3D` with shadows enabled, split shadow maps configured.
- The map mesh imported from Unreal Engine 5 (via FBX export) — see below.
- The player scene instanced in at position `(15.27, 1.77, 11.85)`.
- A loose `RigidBody3D` with a `BoxShape3D` and a ChamferCube mesh — a physics prop that can be knocked around.
- Every mesh in the map has a matching `StaticBody3D` + `CollisionShape3D` added as a child, using `ConcavePolygonShape3D` baked from each mesh.

---

### Map Mesh (Imported from Unreal Engine 5)
**Source file:** `game/player/levels/level_player_test_assets/ThirdPersonMap_Meshes.fbx`
Exported from **Unreal Engine 5.4.4** using the built-in FBX exporter.

**Mesh primitives in the FBX:**
| Mesh | Notes |
|---|---|
| `SM_Cube` | Basic box, used for floors/walls/platforms |
| `SM_Ramp` | Wedge/ramp shape |
| `SM_QuarterCylinder` | Quarter-pipe curved shape |
| `SM_ChamferCube` | Rounded cube (used as a physics prop / decorative object) |

**Materials in the FBX:**
| Material | Color |
|---|---|
| `MI_PrototypeGrid_Gray` | Gray — used for large floor/wall planes |
| `MI_PrototypeGrid_TopDark` | Dark gray — used for platforms, ramps, cylinders |
| `MI_Solid_Blue` | Blue — used on the chamfer cubes (decorative/props) |

**Godot import settings** (`.import` file):
- Scale: `1.0`
- LODs: generated
- Shadow meshes: generated
- Light baking mode: `1` (Static)
- Animations: imported (there's a dummy "Unreal Take" baked in by UE5 FBX exporter — not used)

**Additional material override on the main floor plane:**
- An `ORMMaterial3D` (`new_orm_material_3d.tres`) with a tiled texture (`texture_06.png`, UV scale `16×16×16`) applied to `SM_Cube` (the large ground plane).

---

### Physics Layer
- 3D physics layer 1 named `"World"` in `project.godot`.

---

## What Does NOT Exist Yet
- Jumping
- Gravity manipulation / custom gravity direction (despite the project being named GravityPlayer)
- Gamepad look (input mapped, not scripted)
- Any UI / HUD
- Sound
- Animations on the player mesh
- Multiple levels
- Any game logic / objectives