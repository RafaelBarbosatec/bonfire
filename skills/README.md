# Agent Skills for Bonfire

This directory ships [Agent Skills](https://agentskills.io/specification) with
the `bonfire` package, so AI coding agents know how to use **the installed
version** of Bonfire instead of guessing APIs from older releases.

## Install

Inside your game project (which depends on `bonfire`):

```bash
dart run skills@ get        # pick the skills you want
dart run skills@ get --all  # install everything
```

The CLI scans your direct dependencies for a `skills/` directory and installs
the skills into your agent's folder (`.claude/skills`, `.agents/skills`,
`.cursor/skills`, ...). Update later with `dart run skills@ get` again.

## Available skills

| Skill | Use when |
|---|---|
| `bonfire-getting-started` | creating a project, mounting `BonfireWidget`, fixing assets that don't load |
| `bonfire-player` | player classes, animations, joystick/keyboard input, attacks, life, HUD |
| `bonfire-enemy-ai` | enemies, NPCs, vision, behaviors (chase/attack/patrol), spawning |
| `bonfire-collision-sensor` | hitboxes, blocking movement, non-blocking triggers, pickups |
| `bonfire-map-world` | Tiled maps, `objectsBuilder`, matrix/random maps, infinite world, camera |
| `bonfire-decoration-items` | decorations, chests, pickups, effects, lighting |
| `bonfire-dialog-ui` | `TalkDialog`, `GameInterface` HUD, `TypeWriter`, `MiniMap` |
| `bonfire-v4-api` | 4.x API-object reference and 3.x → 4.x migration traps |

Every skill is grounded in this repository's `example/` app and validated
against `lib/` — when the docs and the source disagree, the source wins (see
the `randomMovement.run` note in `bonfire-v4-api`).

## Writing new skills

- Directory name must start with `bonfire-` (the CLI enforces the package
  prefix).
- `SKILL.md` frontmatter needs `name` (same as the folder) and a `description`
  that says *when* to use it.
- Keep `SKILL.md` under ~500 lines; put long reference material in
  `references/`, helper scripts in `scripts/`, static files in `assets/`.
