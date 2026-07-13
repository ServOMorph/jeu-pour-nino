# Contexte - game_art

## Objectif
Centraliser tous les assets visuels du jeu dans game_art/ et fournir un editeur Godot
pour visualiser, animer et auditer les sprites. Cible player actuelle :
150 px de haut, animations multi-frames, spritesheets.

## Stack
- Godot 4.5 (projet editeur autonome, res:// = game_art/)
- Sprites : pipeline majoritairement en spritesheets pour les entites animees
- Schema animations : game_art/data/animations.json (source de verite)
- Synchro vers jeu : sync.py a la racine projet (gere par zone jeu)

## Etat actuel
La zone game_art reste en maintenance de production.
Le player est maintenant aligne entre `game_art` et `game` sur `idle`, `run`, `jump`, `attack` et les 4 attaques directionnelles.
`player/run` utilise des cases `104x150`, `player/jump` une sheet `3` frames `87x150`, et `player/attack` des cases `150x150`.
`enemy_ground/walk` et `enemy_flyer/fly` restent valides en lecture editeur sur l'etat courant.
L'editeur dispose d'un bouton `Editer sheet`, rend les previews a leur resolution affichee, applique le filtrage lineaire du jeu et se pilote a la souris uniquement.

## Decisions structurantes
- Les controles manette de l'editeur sont bloques a la source ; l'outil se pilote
  uniquement a la souris.
- Le workflow d'animation retenu est : generation de frames separees, detourage,
  normalisation automatique controlee, puis sheet candidate avant validation manuelle.
- `player/run` est le premier cycle complet valide avec cette normalisation automatique,
  conserve en runtime jeu comme nouvelle animation de course.
- `enemy_ground` utilise desormais un gabarit runtime `128x128` avec `walk` en sheet candidate et `idle` regenere sur cette base.
- `enemy_flyer` utilise desormais un gabarit runtime `112x80` avec `fly` en sheet candidate et `idle` regenere sur cette base.
- Une animation mob peut etre branchee en runtime comme candidate si la lecture visuelle est exploitable ; dans l'etat courant, `enemy_ground/walk` et `enemy_flyer/fly` sont deja valides en editeur.
- Le bouton `Editer sheet` permet un ajustement manuel (scale uniforme + position, contraint a la case, apercu temps reel) d'une frame de sheet directement dans l'editeur, avec reecriture du PNG source a la validation ; complement du workflow de normalisation automatique, pas un remplacement.
- `player.jump` suit desormais une sheet `3` frames regeneree completement depuis la reference validee, au lieu d'une pose mono-frame.
- `player.run` utilise des cases `104x150` dans la sheet pour permettre l'edition manuelle sans changer les poses source.
- `player.attack` utilise desormais des cases `150x150`, validees apres elargissement lateral de la sheet sans retouche pixel.
