# Signals - game_art

## Actions ouvertes
- P1 - Stabiliser metrologiquement les nouvelles animations mobs `enemy_ground/walk` et `enemy_flyer/fly`.
  fait quand: les deux lots passent sous les seuils recommandes du workflow (`height <= 3 px`, `width <= 6 px`, pas de derive visible), puis sont valides en lecture editeur.
  ref: `game_art/commands/generation_animation.md`, `game_art/tools/normalize_animation_frames.py`, `game_art/assets/generated_raw/enemy_ground_walk_sheet_candidate.json`, `game_art/assets/generated_raw/enemy_flyer_fly_sheet_candidate.json`, bouton `Editer sheet` de l'editeur (correction manuelle possible sans regeneration complete)
- P2 - Valider dans l'editeur le nouveau `player/jump` 3 frames et le confort d'edition de `player/run` en cases `104x150`.
  fait quand: `player/jump` est juge fluide en lecture editeur et `player/run` peut etre agrandi/recale dans `Editer sheet` sans manque de marge laterale.
  ref: `game_art/assets/player/player_jump_sheet.png`, `game_art/assets/player/player_run_sheet.png`, `game_art/data/animations.json`, `game_art/data/manifest.json`, `python run_editeur.py`

## Blocages

## Derniere session
# Session du 2026-07-12

## Decisions prises
- `player/jump` est regenere comme lot complet de `3` frames via le workflow de reference, puis integre en sheet `87x150`.
- `player/run` garde exactement les memes poses, mais la sheet est reconditionnee en cases `104x150` pour laisser de la marge a `Editer sheet`.
- Le manifest d'audit et le test d'export des specs sont realignes sur ce nouveau gabarit `run`.

## Livrables produits ou modifies
- `game_art/assets/player/player_jump_sheet.png` : nouvelle sheet `jump` 3 frames integree.
- `game_art/assets/generated_raw/player/jump_frames_v2_*` et `player_jump_sheet_candidate_v2.*` : sources, frames detourees/normalisees et rapport du lot retenu.
- `game_art/assets/player/player_run_sheet.png` : sheet `run` reconditionnee en cases plus larges, sans changer les poses.
- `game_art/data/animations.json`, `game_art/data/manifest.json`, `game_art/specs/player.md`, `game_art/editeur/test_specs_export.gd` : config/runtime, audit et specs alignes sur `jump` 3 frames et `run` en `104x150`.

## Hypotheses validees / invalidees
- VALIDE : le second lot `player/jump` respecte les seuils du workflow apres normalisation (`width_span=2`, `height_span=1`, `ground_span=0`).
- VALIDE : elargir `player/run` en `104x150` sans toucher aux pixels suffit pour redonner de la marge laterale exploitable a l'editeur.
- INVALIDE : le premier lot `player/jump` etait integrable tel quel -> batch rejete pour derives metriques excessives, puis regeneration plus stricte autour de la reference.

## Prochaine etape exacte
Valider dans `python run_editeur.py` la lecture de `player/jump` et l'edition de `player/run` en `104x150`, puis reprendre l'action P1 sur les mobs standards.

## Question bloquante pour la session suivante
Aucune
