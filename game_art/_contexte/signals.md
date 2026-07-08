# Signals - game_art

## Actions ouvertes

- [P1] Valider visuellement l'editeur apres suppression du panneau Reference.
  fait quand: `python run_editeur.py` affiche la preview `Produit` centree pour le player et les sprites statiques, sans decalage visible.
  ref: game_art/editeur/main.gd, game_art/editeur/test_preview_center.gd.
- [P2] Valider en jeu les nouveaux sprites boss, mobs et objets gameplay critiques.
  fait quand: `boss_guardian`, `enemy_ground`, `enemy_flyer`, `ore_copper_handmade_v2`, `ore_iron`, `ore_abyssal` et `workbench` sont verifies en jeu sans probleme visible de lisibilite, d'echelle ou d'ancrage.
  ref: game/assets/sprites/enemies/, game/assets/sprites/objects/, game/scenes/enemies/boss.tscn.
- [P3] Decider le sort des PNG player legacy non references.
  fait quand: les anciens PNG player sont soit supprimes/archives, soit exclus explicitement de l'audit, et `game_art/audit_report.md` ne remonte plus de warnings globaux sur `game_art/assets/player/player_*.png`.
  ref: game_art/audit_report.md, game_art/assets/player/, game_art/editeur/audit.gd.
- [P4] Completer les sprites de gisements/minerais dedies.
  fait quand: chaque materiau de `game/data/materials.json` utilise un sprite dedie sans fallback cuivre.
  ref: game_art/backlog_art.md, game/data/materials.json, game_art/assets/objects/.

## Blocages

## Derniere session
# Session du 2026-07-08

## Decisions prises
- Le player ne depend plus d'aucun etat legacy dans `animations.json` : tous les etats passent en `sheet` + `frame_size` + indices.
- Les etats player mono-frame (`idle`, `jump`, `fall`, `hurt`, `dead`) sont encapsules en sheets 1 frame pour unifier totalement jeu et editeur.

## Livrables produits ou modifies
- game_art/assets/player/player_*_sheet.png : sheets runtime ajoutes pour tous les etats player.
- game_art/data/animations.json, game/data/animations.json : player migre a 100% vers le format sheet.
- game_art/editeur/test_specs_export.gd, game_art/editeur/test_audit_ui.gd : attentes alignees sur un player sans fallback legacy.
- game_art/specs/player.md, game_art/audit_report.md : exports regeneres apres migration.

## Hypotheses validees / invalidees
- VALIDE : `test_preview_center`, `test_specs_export`, `test_audit_ui` et `test_audit` passent apres migration du player.
- VALIDE : `game_art/specs/player.md` n'affiche plus aucun etat `legacy` ni anomalie ouverte pour le player.
- EN ATTENTE : validation visuelle interactive dans l'editeur et dans le jeu.

## Prochaine etape exacte
Lancer `python run_editeur.py`, puis `python run_game.py`, et verifier visuellement le player migre en sheet
ainsi que les sprites critiques deja livres. Ensuite trancher si les PNG player legacy doivent etre conserves
comme sources ou exclus du perimetre de l'audit.

## Question bloquante pour la session suivante
Les PNG player legacy non references doivent-ils rester comme sources locales, ou etre retires/exclus de l'audit ?
