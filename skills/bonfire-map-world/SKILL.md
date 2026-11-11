---
name: bonfire-map-world
description: Build Bonfire worlds — Tiled JSON maps, objectsBuilder for enemies/decorations, matrix-generated and random maps, infinite worlds, tile collisions and camera configuration. Use when creating or changing a map, spawning objects from Tiled, generating procedural maps or fixing camera/zoom behavior.
---

# Bonfire — Maps and World (4.x)

A map is a matrix of tiles. Bonfire ships three sources: Tiled JSON,
SpriteFusion JSON and a matrix generator. The map is passed to
`BonfireWidget(map: ...)` and owns tile rendering, collision tiles and the
objects layer.

## 1. Tiled (recommended)

Export from Tiled as **JSON** into `assets/images/...` and load with
`WorldMapReader`:

```dart
BonfireWidget(
  map: WorldMapByTiled(
    WorldMapReader.fromAsset('tiled/map.json'),
    forceTileSize: Vector2.all(32), // optional: override the tile size
    objectsBuilder: {
      'goblin': (TiledObjectProperties p) => Goblin(p.position),
      'chest': (TiledObjectProperties p) => Chest(p.position),
      'spawn': (TiledObjectProperties p) => ComponentSpawner(
            position: p.position,
            area: p.area,
            interval: 500,
            builder: (position) => PotionLife(position, 10),
          ),
    },
  ),
  player: Knight(Vector2(64, 64)),
)
```

The key of `objectsBuilder` is the **object type/name** set on the Tiled
object layer. `TiledObjectProperties` exposes:

| Field | Type |
|---|---|
| `position` | `Vector2` (world position) |
| `size` | `Vector2` |
| `area` | `ShapeHitbox` (the object's collision shape) |
| `rotation` | `double?` |
| `type`, `name` | `String?` |
| `id` | `int?` |
| `others` | `Map<String, dynamic>` (custom properties) |

Custom Tiled properties arrive in `others` — use them to parameterize the
factory (`p.others['damage'] ?? 10`).

Tile collision: tiles marked with collision in the tileset become solid
barriers automatically; do not add hitboxes for walls.

Light occluders: a tile/object layer, or an individual object, with class
`lighting_occluder` becomes a shadow blocker — `WorldMapByTiled` registers it
automatically (no code needed). In object layers you can combine roles:
`collision,lighting_occluder` makes the same wall block movement **and** light.

Maps can also be loaded from a URL: `WorldMapReader.fromNetwork(Uri.parse(...))`.

## 2. SpriteFusion

```dart
WorldMapBySpritefusion(WorldMapReader.fromAsset('spritefusion/map.json'))
```

Same `objectsBuilder` contract.

## 3. Matrix maps (procedural / hand-authored)

```dart
MatrixMapGenerator.generate(
  layers: [
    MatrixLayer(
      axisInverted: true, // true = matrix[y][x], matches what you see in code
      matrix: [
        [0, 0, 0, 0],
        [0, 1, 1, 0],
        [0, 0, 1, 0],
        [0, 0, 0, 0],
      ],
    ),
  ],
  builder: (ItemMatrixProperties prop) {
    // prop.value, prop.position
    // neighbors: valueTop, valueBottom, valueLeft, valueRight,
    //            valueTopLeft, valueTopRight, valueBottomLeft, valueBottomRight
    final sprite = TileModelSprite(
      path: prop.value == 1 ? 'tile_grass.png' : 'tile_water.png',
    );
    return TileModel(x: prop.position.x, y: prop.position.y, sprite: sprite);
  },
)
```

`TileModelSprite` paths follow the same `assets/images/` rule. For terrain
transitions (sand→grass corners), register `MapTerrain` /
`MapTerrainCorners` in a `TerrainBuilder` and pass `builder: terrainBuilder.build`.

Generating the matrix with noise (`fast_noise`, etc.) and feeding it to
`MatrixLayer` is the standard way to build random dungeons/overworlds — see
`example/lib/pages/mini_games/random_map/`.

## 4. Infinite world

```dart
WorldMapInfiniteByTiled(
  WorldMapReader.fromAsset('tiled/pattern.json'),
  type: InfiniteWorldMapType.open, // open | vertical | horizontal
  objectsBuilder: {
    'tree': (p) => Tree(p.position),
  },
)
```

The small map is repeated as a pattern around the camera; chunks load and
unload automatically, so memory stays bounded. Objects from `objectsBuilder`
are recreated per chunk.

## 5. Camera

```dart
cameraConfig: CameraConfig(
  moveOnlyMapArea: true,             // never show outside the map
  movementWindow: Vector2(50, 50),   // dead zone around the player
  zoom: getZoomFromMaxVisibleTile(context, 32, 15), // 15 tiles across
  startFollowPlayer: true,
  angle: 0,
  speed: 1.0,
)
```

Runtime helpers (`gameRef.camera`):

```dart
camera.moveToPlayer();
camera.moveToPlayerAnimated(effectController: EffectController(duration: 1), zoom: 2);
camera.moveToPositionAnimated(position: p, effectController: ...);
camera.moveToTargetAnimated(target: component, followTarget: true);
camera.animateZoom(zoom: Vector2.all(2), effectController: ...);
camera.animateAngle(angle: 0.5, effectController: ...);
camera.shake(intensity: 10, duration: const Duration(milliseconds: 200));
camera.follow(target, maxSpeed: 100);
```

Use `getZoomFromMaxVisibleTile(context, tileSize, tilesVisible)` instead of
hardcoding zoom — it adapts to the device size. It must be called with a
`BuildContext` (i.e. inside `build`).

## Pitfalls

- Only `.json` Tiled exports are supported (no `.tmx`).
- Asset paths are relative to `assets/images/`; the directory must be listed
  in `pubspec.yaml`.
- `objectsBuilder` keys must match the Tiled **type** (or name, depending on
  the export); a typo silently produces no object.
- Objects created by `objectsBuilder` are placed at the object's position;
  size is not applied automatically — pass it in the component constructor.
- Camera `zoom` is a scale factor, not a tile count: `zoom: 2` magnifies.
- Changing `map` at runtime is not supported — rebuild the `BonfireWidget`
  (use a `key`) to load a different map.
- `MatrixLayer(axisInverted: false)` (the default) reads `matrix[x][y]`; most
  hand-written matrices look transposed unless you set `axisInverted: true`.

## Repo references

- `example/lib/pages/mini_games/simple_example/simple_example_game.dart` — Tiled + spawner
- `example/lib/pages/mini_games/tiled_map/game_tiled_map.dart`
- `example/lib/pages/mini_games/random_map/` — noise + `TerrainBuilder`
- `example/lib/pages/mini_games/manual_map/` — matrix map
- `docs/infinite-map.mdx`, `docs/tiled-support.mdx`
