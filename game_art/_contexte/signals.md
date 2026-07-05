# Signals — game_art

## Actions ouvertes

- [P1] Enrichir `game_art/audit_report.md`.
  fait quand: le rapport exporté est regroupé par entité puis par état, avec résumé initial `error` / `warning` / `info`.
  réf: game_art/roadmap_editeur.md (section 4.3), game_art/editeur/main.gd, game_art/audit_report.md.
- [P2] Phase 5.1 : comparaison côte à côte sprite produit / référence.
  fait quand: un second viewport affiche `assets/from_reference/` avec le même zoom que la preview principale.
  réf: game_art/roadmap_editeur.md (phase 5), game_art/assets/from_reference/, game_art/editeur/main.gd.

## Blocages

## Dernière session

# Session du 2026-07-05

## Décisions prises
- Le manifest d'audit passe en schéma par état pour supporter des tailles différentes comme `player.attack` en `48x56`.
- La phase 4 s'appuie sur deux tests headless dédiés : `test_audit.gd` pour le moteur et `test_audit_ui.gd` pour la navigation/export.
- La vue audit est intégrée dans l'éditeur via une boîte de dialogue dédiée, pas via un onglet structurel.

## Livrables produits ou modifiés
- game_art/data/manifest.json : référentiel d'états attendus et tailles cibles par état.
- game_art/editeur/audit.gd : moteur d'audit des sprites et animations.
- game_art/editeur/main.gd : bouton Audit, vue cliquable, tri par sévérité, export `audit_report.md`.
- game_art/editeur/test_audit.gd : validation headless des anomalies attendues.
- game_art/editeur/test_audit_ui.gd : validation headless de la sélection depuis la vue audit et de l'export.
- game_art/audit_report.md : premier export du rapport d'audit.
- game_art/roadmap_editeur.md : phase 4 alignée sur l'état réel, raffinement d'export ajouté.

## Hypothèses validées / invalidées
- VALIDÉ : le moteur d'audit détecte bien état manquant, sprite manquant, sprite orphelin, indice hors grille et placeholders partagés.
- VALIDÉ : la sélection d'une anomalie dans la vue audit repositionne bien l'éditeur sur l'entité/état ciblé.
- EN ATTENTE : enrichissement du format de `audit_report.md` pour éviter un export trop plat.

## Prochaine étape exacte
Enrichir `game_art/audit_report.md` dans l'export de la vue audit :
résumé initial par sévérité puis regroupement strict par entité et par état.

## Question bloquante pour la session suivante
Aucune
