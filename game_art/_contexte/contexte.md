# Contexte - game_art

## Objectif
Centraliser tous les assets visuels du jeu dans game_art/ et fournir un editeur Godot
pour visualiser, animer et auditer les sprites. Cible player actuelle :
150 px de haut, animations multi-frames, spritesheets.

## Stack
- Godot 4.5 (projet editeur autonome, res:// = game_art/)
- Sprites : PNG individuels (migration vers spritesheets en cours)
- Schema animations : game_art/data/animations.json (source de verite)
- Synchro vers jeu : sync.py a la racine projet (gere par zone jeu)

## Etat actuel
La zone game_art reste en maintenance de production.
Le workflow de regeneration d'animation a maintenant ete applique au player puis aux mobs standard.
`enemy_ground/walk` et `enemy_flyer/fly` sont branches comme sheets runtime candidates ; leurs `idle` ont ete regenres pour rester coherents.
Les deux lots mobs restent a stabiliser metrologiquement avant validation finale dans l'editeur.
L'editeur rend les previews a leur resolution affichee, avec filtrage lineaire coherent avec le jeu, et se pilote a la souris uniquement.

## Decisions structurantes
- Le decor du HUB est livre comme fond fixe `1920x1080`, pret pour branchement cote jeu.
- L'atelier runtime utilise desormais un sprite `160x144` avec collision, zone
  d'interaction et ancrage au sol realignes.
- Le zoom de preview doit rendre le viewport a la resolution affichee, puis agrandir
  le sprite ; il ne doit pas agrandir un rendu interne de faible resolution.
- Les previews 2D standard emploient le filtrage lineaire, comme le runtime du jeu.
- Les controles manette de l'editeur sont bloques a la source ; l'outil se pilote
  uniquement a la souris.
- Le workflow d'animation retenu est : generation de frames separees, detourage,
  normalisation automatique controlee, puis sheet candidate avant validation manuelle.
- `player/run` est le premier cycle complet valide avec cette normalisation automatique,
  conserve en runtime jeu comme nouvelle animation de course.
- `enemy_ground` utilise desormais un gabarit runtime `128x128` avec `walk` en sheet candidate et `idle` regenere sur cette base.
- `enemy_flyer` utilise desormais un gabarit runtime `112x80` avec `fly` en sheet candidate et `idle` regenere sur cette base.
- Une animation mob peut etre branchee en runtime comme candidate si la lecture visuelle est exploitable, mais elle n'est consideree validee qu'une fois les derives metriques revenues dans les seuils du workflow.
