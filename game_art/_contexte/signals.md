# Signals - game_art

## Actions ouvertes
- P1 - Stabiliser metrologiquement les nouvelles animations mobs `enemy_ground/walk` et `enemy_flyer/fly`.
  fait quand: les deux lots passent sous les seuils recommandes du workflow (`height <= 3 px`, `width <= 6 px`, pas de derive visible), puis sont valides en lecture editeur.
  ref: `game_art/commands/generation_animation.md`, `game_art/tools/normalize_animation_frames.py`, `game_art/assets/generated_raw/enemy_ground_walk_sheet_candidate.json`, `game_art/assets/generated_raw/enemy_flyer_fly_sheet_candidate.json`

## Blocages

## Derniere session
# Session du 2026-07-12

## Decisions prises
- Les mobs standards passent a leurs gabarits runtime definitifs : `enemy_ground` = `128x128`, `enemy_flyer` = `112x80`, boss inchange.
- Le workflow `generation_animation.md` a ete etendu aux mobs avec production de deux cycles multi-frames runtime candidats : `enemy_ground/walk` et `enemy_flyer/fly`.
- Les sprites `idle` de `enemy_ground` et `enemy_flyer` ont ete regenres pour suivre les nouvelles animations et rester coherents avec leurs gabarits runtime.

## Livrables produits ou modifies
- game_art/assets/enemies/enemy_ground.png, enemy_flyer.png : sprites `idle` regeneres et rebranches.
- game_art/assets/enemies/enemy_ground_walk_sheet.png, enemy_flyer_fly_sheet.png : nouvelles sheets multi-frames runtime candidates pour les mobs standard.
- game_art/assets/generated_raw/enemy_ground_* et enemy_flyer_* : sources, alpha, frames normalisees et rapports JSON de regeneration.
- game_art/data/animations.json, game_art/data/manifest.json, game_art/specs/enemy_ground.md, game_art/specs/enemy_flyer.md : etats runtime et gabarits realignes.

## Hypotheses validees / invalidees
- VALIDE : le workflow `generation_animation.md` est reutilisable sur des mobs et produit des sheets candidates exploitables.
- INVALIDE : la simple regeneration frame par frame des mobs suffit a rester dans les seuils metriques recommandes -> pivot vers une reprise ciblee des lots trop derives.
- EN ATTENTE : validation editeur finale de `enemy_ground/walk` et `enemy_flyer/fly` apres reduction des derives de largeur/hauteur.

## Prochaine etape exacte
Reprendre les cycles `enemy_ground/walk` et `enemy_flyer/fly` avec un gabarit plus stable.
Mesurer chaque nouveau lot contre les rapports JSON actuels, puis ne remplacer les sheets runtime qu'une fois les derives metriques ramenes dans les seuils du workflow.

## Question bloquante pour la session suivante
Aucune
