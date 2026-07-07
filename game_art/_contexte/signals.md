# Signals - game_art

## Actions ouvertes

- [P1] Valider en jeu le set joueur produit.
  fait quand: `idle`, `run`, `jump`, `fall`, `attack`, `hurt` et `dead` sont verifies en jeu sans probleme visible d'echelle, d'ancrage sol ou d'orientation.
  ref: game/assets/sprites/player/, game/data/animations.json, game_art/data/animations.json.
- [P2] Migrer le player vers un vrai set spritesheet complet.
  fait quand: les etats legacy du player quittent les PNG unitaires pour un format `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
  ref: game_art/roadmap_editeur.md (phase 5), game_art/data/animations.json, game/scripts/animation_driver.gd, game_art/backlog_art.md.

## Blocages

## Derniere session
# Session du 2026-07-07

## Decisions prises
- Le workflow valide pour les sprites personnage est : generation `image_gen` HD,
  fond chroma-key, suppression locale du fond, resize exact a la taille cible,
  puis integration.
- Le set joueur source doit etre oriente vers la droite ; le flip en jeu reste
  le comportement standard du driver.
- L'attaque ne doit pas etre compensee par un offset vertical artificiel :
  `player.attack.offset` est remis a `[0, 0]`.

## Livrables produits ou modifies
- game_art/assets/player/player_idle_v2.png, player_run1.png, player_run2.png, player_run_sheet.png, player_jump.png, player_attack.png : set joueur HD redimensionne, oriente a droite et synchronise vers `game/`.
- game_art/assets/generated_raw/player_run1_raw.png, player_run2_raw.png, player_jump_raw.png, player_attack_raw.png : sources brutes conservees pour iteration.
- game_art/data/animations.json : `player.run.frame_size` passe en `87x150` et `player.attack.offset` revient a `0`.
- docs/workflow_image_gen_fable5.md, docs/process_generation_sprites.md, game_art/backlog_art.md : workflow et handoff alignes sur le pipeline retenu.
- game_art/editeur/test_audit_ui.gd et game_art/editeur/test_specs_export.gd : attentes alignees sur l'etat reel du player.

## Hypotheses validees / invalidees
- VALIDE : une image source HD + detourage + resize exact peut produire un rendu
  joueur accepte visuellement.
- VALIDE : `hurt` et `dead` restent coherents en reutilisant `idle`, et `fall` en reutilisant `jump`.
- EN ATTENTE : validation visuelle complete en jeu du set joueur apres sync.

## Prochaine etape exacte
Verifier en jeu l'ensemble des etats du player produits cette session.
Si le rendu est valide, lancer ensuite la migration vers un vrai set spritesheet.

## Question bloquante pour la session suivante
Aucune
