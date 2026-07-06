# Signals - game_art

## Actions ouvertes

- [P1] Migration spritesheet complete des etats legacy restants.
  fait quand: tous les etats de `animations.json` sont en format `sheet` + `frame_size` + indices, sans fallback legacy dans les drivers.
  ref: game_art/roadmap_editeur.md (phase 5), game_art/data/animations.json, game_art/editeur/animation_driver.gd, game/scripts/animation_driver.gd.
- [P2] Executer une validation complete du cycle art une fois de nouveaux sheets produits.
  fait quand: un cycle complet `sheet produit -> depot assets -> reglages editeur -> audit -> sync -> validation jeu` est execute une fois.
  ref: game_art/README.md, game_art/specs/, game_art/audit_report.md, game_art/roadmap_editeur.md.

## Blocages

- Nouveaux assets spritesheet multi-frames absents pour les etats encore en legacy.

## Derniere session

# Session du 2026-07-06

## Decisions prises
- La phase 4.3 est close avec export d'audit structure par severite, entite puis etat.
- La comparaison produit/reference se fait directement dans la preview via un second viewport synchronise en zoom.
- Les fiches `specs/<entity>.md` deviennent le format de brief genere par l'editeur pour la suite du travail art.

## Livrables produits ou modifies
- game_art/editeur/main.gd : export audit enrichi, preview de reference cote a cote et export des specs par entite.
- game_art/editeur/test_audit_ui.gd : validation du nouveau format d'export `audit_report.md`.
- game_art/editeur/test_reference_preview.gd : validation headless de la preview de reference et du zoom synchronise.
- game_art/editeur/test_specs_export.gd : validation headless de l'export `specs/<entity>.md`.
- game_art/audit_report.md : rapport exporte au nouveau format.
- game_art/README.md : documentation d'usage de l'editeur et du flux de travail.
- game_art/roadmap_editeur.md : phases 4.3, 5.1, export specs et documentation coches.

## Hypotheses validees / invalidees
- VALIDE : l'export `audit_report.md` couvre bien resume par severite et regroupement entite/etat.
- VALIDE : la preview de reference charge les assets existants et garde le meme zoom que la preview principale.
- EN ATTENTE : migration spritesheet complete, bloquee tant que les nouveaux sheets n'existent pas.

## Prochaine etape exacte
Produire de nouveaux spritesheets pour remplacer les etats encore en legacy, puis
basculer `animations.json` et retirer le fallback legacy des drivers jeu/editeur dans le meme commit.

## Question bloquante pour la session suivante
Quels etats sont produits en premier en vrai spritesheet multi-frame ?
