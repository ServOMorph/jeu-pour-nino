# Signals - game_art

## Actions ouvertes

- [P1] Valider visuellement l'editeur apres suppression du panneau Reference.
  fait quand: `python run_editeur.py` affiche la preview `Produit` centree pour le player et les sprites statiques, sans decalage visible.
  ref: game_art/editeur/main.gd, game_art/editeur/test_preview_center.gd.
- [P2] Valider en jeu les nouveaux sprites boss, mobs et objets gameplay critiques.
  fait quand: `boss_guardian`, `enemy_ground`, `enemy_flyer`, `ore_copper_handmade_v2`, `ore_iron`, `ore_abyssal` et `workbench` sont verifies en jeu sans probleme visible de lisibilite, d'echelle ou d'ancrage.
  ref: game/assets/sprites/enemies/, game/assets/sprites/objects/, game/scenes/enemies/boss.tscn.
- [P3] Migrer le player vers un vrai set spritesheet complet.
  fait quand: les etats legacy du player, y compris les 5 directions d'attaque, quittent les PNG unitaires pour un format `sheet` + `frame_size` + indices, sans fallback legacy cote jeu/editeur.
  ref: game_art/roadmap_editeur.md (phase 5), game_art/data/animations.json, game/scripts/animation_driver.gd, game_art/backlog_art.md, game/scripts/player.gd.
- [P4] Completer les sprites de gisements/minerais dedies.
  fait quand: chaque materiau de `game/data/materials.json` utilise un sprite dedie sans fallback cuivre.
  ref: game_art/backlog_art.md, game/data/materials.json, game_art/assets/objects/.

## Blocages

## Derniere session
# Session du 2026-07-07

## Decisions prises
- Le panneau `Reference` est supprime : le workflow actuel valide uniquement la preview `Produit`.
- La preview `Produit` centre explicitement la texture de frame affichee.
- Le manifest inclut les 5 etats d'attaque player directionnels en `129x150`.

## Livrables produits ou modifies
- game_art/editeur/main.gd : panneau `Reference` retire, centrage `Produit` corrige.
- game_art/editeur/test_reference_preview.gd : supprime.
- game_art/editeur/test_preview_center.gd : test headless de centrage ajoute.
- game_art/data/manifest.json : etats `attack_*` directionnels ajoutes au player.
- game_art/README.md, game_art/roadmap_editeur.md : documentation alignee.

## Hypotheses validees / invalidees
- VALIDE : les tests headless `test_audit_ui`, `test_preview_center` et `test_specs_export` passent.
- VALIDE : l'export specs retrouve une taille cible pour les attaques player directionnelles.
- EN ATTENTE : validation visuelle interactive de l'editeur lance via `python run_editeur.py`.

## Prochaine etape exacte
Relancer l'editeur en UI et confirmer que `Produit` reste centre sur les entites animees
et les sprites statiques.

## Question bloquante pour la session suivante
Aucune
