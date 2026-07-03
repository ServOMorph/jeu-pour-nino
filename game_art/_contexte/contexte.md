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
Phase 0 et Phase 1 terminées. Phase 2.1 terminée : l'éditeur se lance sans erreur,
affiche toolbar + galerie (entités/états) + preview animée dans 3 panneaux distincts.
Prochaine étape : Phase 2.2 (infos frame, fond damier, état play/pause, textures
manquantes).

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
