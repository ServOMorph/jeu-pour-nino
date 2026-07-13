# Signals - game_art

## Actions ouvertes
- P1 - Realigner `game/` sur l'etat courant valide dans `game_art` pour `player/run` et `player/jump`.
  fait quand: `game/data/animations.json` reprend `player/run` en `104x150` et `player/jump` en lot `3` frames, les sheets runtime cote `game/assets/` sont resynchronisees, puis une verification en jeu confirme l'absence de regression visible.
  ref: `game_art/data/animations.json`, `game/data/animations.json`, `game_art/assets/player/player_run_sheet.png`, `game_art/assets/player/player_jump_sheet.png`, `game/assets/sprites/player/player_run_sheet.png`, `game/assets/sprites/player/player_jump_sheet.png`, `python run_game.py`

## Blocages

## Derniere session
# Session du 2026-07-13

## Decisions prises
- `player/jump` est regenere comme lot complet de `3` frames via le workflow de reference, puis integre en sheet `87x150`.
- `player/run` garde exactement les memes poses, mais la sheet est reconditionnee en cases `104x150` pour laisser de la marge a `Editer sheet`.
- Le manifest d'audit et le test d'export des specs sont realignes sur ce nouveau gabarit `run`.
- La validation manuelle en editeur confirme `P1` et `P2` comme closes.
- Le suivi doit distinguer l'etat valide dans `game_art` de l'etat encore desynchronise dans `game/` pour `run` et `jump`.

## Livrables produits ou modifies
- `game_art/assets/player/player_jump_sheet.png` : nouvelle sheet `jump` 3 frames integree.
- `game_art/assets/generated_raw/player/jump_frames_v2_*` et `player_jump_sheet_candidate_v2.*` : sources, frames detourees/normalisees et rapport du lot retenu.
- `game_art/assets/player/player_run_sheet.png` : sheet `run` reconditionnee en cases plus larges, sans changer les poses.
- `game_art/data/animations.json`, `game_art/data/manifest.json`, `game_art/specs/player.md`, `game_art/editeur/test_specs_export.gd` : config/runtime, audit et specs alignes sur `jump` 3 frames et `run` en `104x150`.

## Hypotheses validees / invalidees
- VALIDE : le second lot `player/jump` respecte les seuils du workflow apres normalisation (`width_span=2`, `height_span=1`, `ground_span=0`).
- VALIDE : elargir `player/run` en `104x150` sans toucher aux pixels suffit pour redonner de la marge laterale exploitable a l'editeur.
- VALIDE : `enemy_ground/walk` et `enemy_flyer/fly` sont juges exploitables apres validation editeur.
- INVALIDE : le runtime `game/` etait deja aligne sur le dernier etat `game_art` pour `player/run` et `player/jump`.
- INVALIDE : le premier lot `player/jump` etait integrable tel quel -> batch rejete pour derives metriques excessives, puis regeneration plus stricte autour de la reference.

## Prochaine etape exacte
Lancer la synchronisation vers `game/` du nouveau `player/run` (`104x150`) et du
nouveau `player/jump` (`3` frames), puis verifier ces deux etats en jeu.

## Question bloquante pour la session suivante
Aucune
