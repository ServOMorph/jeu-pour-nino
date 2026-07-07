# Signals - game_art

## Actions ouvertes

- [P1] Valider en jeu les nouveaux sprites boss, mobs et objets gameplay critiques.
  fait quand: `boss_guardian`, `enemy_ground`, `enemy_flyer`, `ore_copper_handmade_v2`, `ore_iron`, `ore_abyssal` et `workbench` sont verifies en jeu sans probleme visible de lisibilite, d'echelle ou d'ancrage.
  ref: game/assets/sprites/enemies/, game/assets/sprites/objects/, game/scenes/enemies/boss.tscn.
- [P2] Migrer le player vers un vrai set spritesheet complet.
  fait quand: les etats legacy du player quittent les PNG unitaires pour un format `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
  ref: game_art/roadmap_editeur.md (phase 5), game_art/data/animations.json, game/scripts/animation_driver.gd, game_art/backlog_art.md.
- [P3] Completer les sprites de gisements/minerais dedies.
  fait quand: chaque materiau de `game/data/materials.json` utilise un sprite dedie sans fallback cuivre.
  ref: game_art/backlog_art.md, game/data/materials.json, game_art/assets/objects/.

## Blocages

## Derniere session
# Session du 2026-07-07

## Decisions prises
- Le set joueur HD est valide en jeu et devient la base visuelle de reference.
- Les sprites boss, mobs et objets gameplay critiques sont desormais regeneres en HD
  puis redimensionnes a la taille runtime exacte.

## Livrables produits ou modifies
- game_art/assets/enemies/boss_guardian.png, enemy_ground.png, enemy_flyer.png et copies dans `game/assets/sprites/enemies/` : sprites refaits et synchronises.
- game_art/assets/objects/ore_copper_handmade_v2.png, ore_copper.png, ore_iron.png, ore_abyssal.png, workbench.png et copies dans `game/assets/sprites/objects/` : sprites refaits et synchronises.
- game_art/data/manifest.json et game/scenes/enemies/boss.tscn : tailles runtime ennemies realignees ; boss porte a `389x500` avec collisions associees.

## Hypotheses validees / invalidees
- VALIDE : le pipeline generation HD + detourage + resize exact fonctionne aussi pour les mobs et objets gameplay.
- VALIDE : la validation en jeu du set joueur confirme la viabilite du pipeline retenu.
- EN ATTENTE : coherence visuelle et lisibilite en jeu du boss, des mobs et des objets refaits.

## Prochaine etape exacte
Verifier en jeu le boss, les mobs de base et les objets gameplay refaits.
Si le rendu est valide, poursuivre la migration du player vers un vrai set spritesheet
et continuer la couverture des sprites de materiaux dedies.

## Question bloquante pour la session suivante
Aucune
