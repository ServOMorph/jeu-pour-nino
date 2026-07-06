# Contexte - game_art

## Objectif
Centraliser tous les assets visuels du jeu dans game_art/ et fournir un editeur Godot
pour visualiser, animer et auditer les sprites. Cible graphique : qualite Terraria
(pixel art 40x56 player, animations multi-frames, spritesheets).

## Stack
- Godot 4.5 (projet editeur autonome, res:// = game_art/)
- Sprites : PNG individuels (migration vers spritesheets en cours)
- Schema animations : game_art/data/animations.json (source de verite)
- Synchro vers jeu : sync.py a la racine projet (gere par zone jeu)

## Etat actuel
Phases 0, 1, 2, 3 et 4 sont closes cote editeur.
La phase 5 est avancee : comparaison produit/reference, export des specs par entite
et documentation d'usage sont en place et valides en headless.
Le principal reste ouvert hors tooling : remplacer les etats legacy par de vrais sheets.

## Decisions structurantes
- UI multi-panneaux : ne jamais mettre plus de 2 enfants dans un `HSplitContainer`
  (comportement non defini / superposition) - imbriquer des splits si besoin d'un 3e panneau.
- Sauvegarde `animations.json` : toujours appeler `JSON.stringify(data, indent, false)`
  (sort_keys=false explicite) - le defaut Godot (true) reordonne alphabetiquement
  tout le fichier a chaque sauvegarde et rend les diffs Git illisibles.
- Verification des changements GDScript sans interaction souris/clavier : script de
  test headless (`Godot --headless --script res://editeur/<script>.gd -- <mode>`)
  qui appelle directement les fonctions de `main.gd`/`inspector.gd` plutot que de
  piloter l'OS - plus fiable qu'une automatisation pixel, voir
  `game_art/editeur/test_save_roundtrip.gd`.
- L'inspecteur doit rester utilisable en demi-ecran : panneau droit compact,
  controles empiles si necessaire, pas de dependance a un scroll horizontal.
- `player.run.fps` est valide a 8.1 depuis la cloture Phase 3.3 du 2026-07-05.
- Le manifest d'audit utilise un schema par etat, pas par entite, pour supporter
  des tailles differentes comme `player.attack` en `48x56`.
- Les regressions de la phase audit sont verifiees en headless via
  `test_audit.gd` et `test_audit_ui.gd`.
- La vue audit est portee par une `AcceptDialog` avec `Tree` trie par severite,
  cliquable et exportable, sans refonte de layout principal.
- La preview de reference resout les PNG de `assets/from_reference/` par convention de
  nommage et applique exactement le meme zoom que la preview principale.
- Les fiches `specs/<entity>.md` sont generees depuis `animations.json`, `manifest.json`
  et l'audit courant pour servir de brief art directement exploitable.
