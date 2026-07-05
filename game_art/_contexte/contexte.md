# Contexte — game_art

## Objectif
Centraliser tous les assets visuels du jeu dans game_art/ et fournir un éditeur Godot
pour visualiser, animer et auditer les sprites. Cible graphique : qualité Terraria
(pixel art 40×56 player, animations multi-frames, spritesheets).

## Stack
- Godot 4.5 (projet éditeur autonome, res:// = game_art/)
- Sprites : PNG individuels (migration vers spritesheets en cours)
- Schéma animations : game_art/data/animations.json (source de vérité)
- Synchro vers jeu : sync.py à la racine projet (géré par zone jeu)

## État actuel
Phases 0, 1, 2, 3 et 4 sont implémentées côté éditeur.
Le manifest d'audit, le moteur d'audit et la vue audit cliquable avec export sont en place
et validés en headless. Le rapport exporté est encore minimal sur sa structure.
Prochaine étape : enrichir `audit_report.md`, puis attaquer les finitions de phase 5.

## Décisions structurantes
- UI multi-panneaux : ne jamais mettre plus de 2 enfants dans un `HSplitContainer`
  (comportement non défini / superposition) — imbriquer des splits si besoin d'un 3e panneau.
- Sauvegarde `animations.json` : toujours appeler `JSON.stringify(data, indent, false)`
  (sort_keys=false explicite) — le défaut Godot (true) réordonne alphabétiquement
  tout le fichier à chaque sauvegarde et rend les diffs Git illisibles.
- Vérification des changements GDScript sans interaction souris/clavier : script de
  test headless (`Godot --headless --script res://editeur/<script>.gd -- <mode>`)
  qui appelle directement les fonctions de `main.gd`/`inspector.gd` plutôt que de
  piloter l'OS — plus fiable qu'une automatisation pixel, voir
  `game_art/editeur/test_save_roundtrip.gd`.
- L'inspecteur doit rester utilisable en demi-écran : panneau droit compact,
  contrôles empilés si nécessaire, pas de dépendance à un scroll horizontal.
- `player.run.fps` est validé à 8.1 depuis la clôture Phase 3.3 du 2026-07-05.
- Le manifest d'audit utilise un schéma par état, pas par entité, pour supporter
  des tailles différentes comme `player.attack` en `48x56`.
- Les régressions de la phase audit sont vérifiées en headless via
  `test_audit.gd` et `test_audit_ui.gd`.
- La vue audit est portée par une `AcceptDialog` avec `Tree` trié par sévérité,
  cliquable et exportable, sans refonte de layout principal.
