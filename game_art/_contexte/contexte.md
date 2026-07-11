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
La zone game_art reste en maintenance de production, avec la boucle player presque close.
`player/idle` et les 4 attaques directionnelles sont maintenant valides en lecture editeur.
`player/attack` reste le dernier etat player a valider manuellement, avec le flux `Recharger`.
Le decor du HUB est livre comme fond fixe `1920x1080` dans `assets/tiles/`.
L'atelier runtime a ete regenere en `160x144` et realigne cote jeu pour rester coherent en scene.

## Decisions structurantes
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
- Les 4 attaques directionnelles du player suivent desormais la meme sequence runtime
  que `player/attack` : `0,1,2,3,3,3,2,1,0`, apres regeneration complete des frames.
- Les 4 attaques directionnelles et `player/idle` sont valides en lecture editeur ;
  `player/attack` reste le dernier controle visuel player ouvert.
- Le decor du HUB est livre comme fond fixe `1920x1080`, pret pour branchement cote jeu.
- L'atelier runtime utilise desormais un sprite `160x144` avec collision, zone
  d'interaction et ancrage au sol realignes.
