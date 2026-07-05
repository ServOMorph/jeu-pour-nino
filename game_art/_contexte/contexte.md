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
Phases 0, 1, 2 terminées. Phase 3 en cours : inspecteur (3.1) et sauvegarde
atomique (3.2) implémentés et testés en headless. Reste 3.3 : vérification
manuelle en conditions réelles (édition via l'inspecteur, sync, jeu) — non
automatisable, nécessite une session interactive dans l'éditeur Godot.

## Décisions structurantes
- game_art/ = racine du projet Godot éditeur (res:// pointe ici)
- game/assets/sprites/ et game/data/animations.json = copies générées (ne pas éditer manuellement)
- Format sprites cible = spritesheets (grille de frames, découpe AtlasTexture)
- Schéma animations.json étendu avec champs sheet/frame_size/frames (rétro-compatible)
- Périmètre zone game_art : éditeur + sprites + animations. Contrôles et affichage = zone jeu.
- Typage GDScript des scripts sans class_name : préférer `const X := preload("res://...")`
  + `var v: X` plutôt que `class_name`, pour rester robuste sans cache `.godot/` généré.
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
