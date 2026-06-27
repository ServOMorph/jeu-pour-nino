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
game_art/ est la source de vérité des sprites (47 fichiers) et d'animations.json.
project.godot éditeur créé (res:// = game_art/), éditeur pas encore développé.
Phase 0 partiellement terminée. Phase 1 (spritesheets) à démarrer.

## Décisions structurantes
- game_art/ = racine du projet Godot éditeur (res:// pointe ici)
- game/assets/sprites/ et game/data/animations.json = copies générées (ne pas éditer manuellement)
- Format sprites cible = spritesheets (grille de frames, découpe AtlasTexture)
- Schéma animations.json étendu avec champs sheet/frame_size/frames (rétro-compatible)
- Périmètre zone game_art : éditeur + sprites + animations. Contrôles et affichage = zone jeu.
