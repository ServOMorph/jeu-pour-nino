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
La zone game_art reste en maintenance de production sur les animations player.
L'etat `player/idle` a ete remplace par une nouvelle sheet 6 frames, lue en pratique sur `0,1,2,3,5` a `5 fps`.
L'etat `player/attack` conserve sa regeneration complete et sa sequence `0,1,2,3,3,3,2,1,0`.
Les sources brutes de regeneration sont conservees dans `game_art/assets/generated_raw/player/`.
La validation manuelle finale de `idle`, puis de `attack`, reste a faire dans l'editeur.

## Decisions structurantes
- Le manifest d'audit des ennemis doit refleter les dimensions runtime reelles des assets pour rester coherent avec l'integration jeu.
- La scene `boss.tscn` aligne desormais visuel et collisions sur un gabarit `389x500`.
- Le panneau `Reference` de l'editeur est supprime : les references visuelles ne sont
  plus affichees dans le workflow courant.
- La preview `Produit` utilise `AnimatedSprite2D.centered = false` et centre la texture
  de la frame courante explicitement dans le viewport.
- Le player utilise desormais uniquement des etats `sheet`, y compris les attaques
  directionnelles et les etats mono-frame encapsules en sheet 1 frame.
- Les PNG player legacy sont conserves comme sources dans `assets/player/legacy_archive/`
  et exclus explicitement de l'audit.
- Les gisements exploitent maintenant des sprites dedies par materiau, sans fallback
  cuivre pour les ressources minables runtime.
- Le Veilleur des Cendres est livre comme set statique runtime avec projectile d'ash
  dedie ; les reglages fins de depart/visibilite restent pilotes cote jeu.
- Le bouton `Recharger` de l'editeur est le flux standard pour relire assets et
  `animations.json` sans redemarrer Godot.
- Une animation a refaire doit etre regeneree integralement depuis une frame de
  reference validee ; corriger des frames isolees cree des derives de gabarit.
- Le nouvel `idle` du player est cadence a `5 fps` sur la sequence `0,1,2,3,5` :
  la frame `4.0` est exclue tant qu'elle n'est pas regeneree proprement.
