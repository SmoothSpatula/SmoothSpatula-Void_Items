### v0.1.14
- Replaced some placeholder sprites with some made by the community
    - Lost Seer's Lenses by **TangoKnight**
    - Polylute by **Goatnorth**
    - Pluripotent Larva by **Goatnorth**
    - Voidsent Flame by **ENNWAY**

### v0.1.13
- Collapse : Fixed buggy calculation of buff count

### v0.1.12
- Collapse : Fixed a bug where the buff would try to damage an invalid instance
- PlasmaShrimp : Added more checks to prevent midhook crash

### v0.1.11
- PlasmaShrimp : Added null check to prevent midhook crash

### v0.1.10
- onPickupCollected callback : check for non item pickup
- benthicBloom : now using Item.StackKind.NORMAL every time

### v0.1.9
- PlasmaShrimp and Polylute : added checks for instance before using fire_direct

### v0.1.8
- PlasmaShrimp : Fixed shield color hook crash, color change now happens individually for each player on the HUD
- DisableAutoPickup : Added as a dependency to disable automatically picking up void items
- Updated Readme

### v0.1.7
- PlasmaShrimp : It was unstable, removing the dynamic hook for now

### v0.1.6
- PlasmaShrimp : Pink shield color via dynamic hooks (could be unstable)

### v0.1.5
- PluripotentLarva `actor_death` hook : death check now matches Dio's

### v0.1.4
- PluripotentLarva Shader : set gpu_set_blendenable to avoid a black screen
- Void Cradle : Added a ping sprite and ping name language entry

### v0.1.3
- ReturnsApi multiplayer tag set to true

### v0.1.2
- Multiplayer implementation
- VoidCradle : Added text

### v0.1.1
- Safer Spaces : Damage dodge instance wrapping fix
