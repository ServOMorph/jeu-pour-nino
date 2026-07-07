# Signals - game_art

## Actions ouvertes

- [P1] Valider en jeu les nouveaux sprites boss, mobs et objets gameplay critiques.
  fait quand: `boss_guardian`, `enemy_ground`, `enemy_flyer`, `ore_copper_handmade_v2`, `ore_iron`, `ore_abyssal` et `workbench` sont verifies en jeu sans probleme visible de lisibilite, d'echelle ou d'ancrage.
  ref: game/assets/sprites/enemies/, game/assets/sprites/objects/, game/scenes/enemies/boss.tscn.
- [P2] Migrer le player vers un vrai set spritesheet complet.
  fait quand: les etats legacy du player, y compris les 5 directions d'attaque, quittent les PNG unitaires pour un format `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
  ref: game_art/roadmap_editeur.md (phase 5), game_art/data/animations.json, game/scripts/animation_driver.gd, game_art/backlog_art.md, game/scripts/player.gd.
- [P3] Completer les sprites de gisements/minerais dedies.
  fait quand: chaque materiau de `game/data/materials.json` utilise un sprite dedie sans fallback cuivre.
  ref: game_art/backlog_art.md, game/data/materials.json, game_art/assets/objects/.

## Blocages

## Derniere session
# Session du 2026-07-07

## Decisions prises
- Le set d'attaque du player est etendu a 5 directions source (`droite`, `haut-droite`,
  `bas-droite`, `haut`, `bas`) avec miroir a gauche gere par le jeu.
- Les attaques restent en format legacy `frames = liste de PNG` ; l'editeur permet deja
  d'ajuster fps/offset/ordre, mais la vraie cible reste la migration en spritesheet.

## Livrables produits ou modifies
- game_art/assets/player/player_attack*.png et copies dans `game/assets/sprites/player/` :
  set d'attaque multi-direction produit (`impact` + `transition`).
- game_art/assets/generated_raw/player/*.png : sources brutes de generation conservees.
- game_art/data/animations.json, game/data/animations.json et game/scripts/player.gd :
  directions d'attaque, ordre des frames et tenue de l'impact final mis a jour.

## Hypotheses validees / invalidees
- VALIDE : le pipeline generation HD + detourage + resize exact tient aussi pour un set
  d'attaque multi-direction du player.
- VALIDE : l'editeur sait deja relire et regler les attaques legacy via `animations.json`.
- EN ATTENTE : validation visuelle en jeu du ressenti exact des nouvelles attaques.

## Prochaine etape exacte
Verifier en jeu les 5 directions d'attaque du player et leur timing.
Si le ressenti est valide, convertir ensuite ces attaques en vrai spritesheet pour rendre
leur reglages plus confortables dans l'editeur.

## Question bloquante pour la session suivante
Aucune
