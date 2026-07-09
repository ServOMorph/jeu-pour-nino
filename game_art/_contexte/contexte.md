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
La zone game_art est en maintenance outillage + production.
L'editeur dispose maintenant d'un bouton `Recharger` pour relire assets et `animations.json` sans relance.
L'etat `player/attack` a ete regenere en 4 frames uniques a partir d'une frame de reference, puis relu via la sequence `0,1,2,3,3,3,2,1,0`.
Les sources HD de regeneration sont conservees dans `game_art/assets/generated_raw/player/`.
La validation manuelle finale de la fluidite de `player/attack` reste a faire dans l'editeur.

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
