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
Phase 0 et Phase 1 terminées. Phase 2 en cours (WIP).
animation_driver.gd (jeu) supporte spritesheets via AtlasTexture, rétro-compatible PNG.
État run player migré en spritesheet (player_run_sheet.png 28×24), validé en jeu.
Éditeur Phase 2 : fichiers créés (main.tscn + main.gd + animation_driver.gd éditeur),
fenêtre Godot s'ouvre mais rendu gris — bug UI à corriger session suivante.

## Décisions structurantes
- game_art/ = racine du projet Godot éditeur (res:// pointe ici)
- game/assets/sprites/ et game/data/animations.json = copies générées (ne pas éditer manuellement)
- Format sprites cible = spritesheets (grille de frames, découpe AtlasTexture)
- Schéma animations.json étendu avec champs sheet/frame_size/frames (rétro-compatible)
- Périmètre zone game_art : éditeur + sprites + animations. Contrôles et affichage = zone jeu.
