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
Phases 0, 1, 2, 3 et 4 sont closes cote editeur.
La phase 5 reste ouverte : les attaques player sont en 5 directions mais encore legacy.
Le panneau `Reference` a ete retire ; la preview `Produit` est le controle visuel unique.
Le centrage `Produit` est corrige et couvert par `test_preview_center.gd`.
Boss, mobs et objets gameplay critiques restent livres ; validation visuelle en jeu encore a faire.

## Decisions structurantes
- Les sprites source du player doivent etre orientes vers la droite ; le flip du jeu
  reste standard et ne doit pas compenser une orientation source inverse.
- Le set joueur HD est valide en jeu depuis le 2026-07-07 et devient la base visuelle de reference pour la suite de la production.
- Pour les mobs, boss et objets gameplay, le workflow valide est : generation HD sur fond chroma-key, detourage local, puis resize exact a la taille runtime.
- Le manifest d'audit des ennemis doit refleter les dimensions runtime reelles des assets pour rester coherent avec l'integration jeu.
- La scene `boss.tscn` aligne desormais visuel et collisions sur un gabarit `389x500`.
- Les attaques multi-direction du player sont pour l'instant livrees en etats legacy
  distincts (`attack`, `attack_up`, `attack_down`, `attack_up_diag`, `attack_down_diag`).
- Tant que ces attaques restent en legacy, l'editeur permet d'ajuster fps, offsets et
  ordre des frames, mais pas d'ajouter de nouveaux chemins PNG depuis l'inspecteur.
- Le panneau `Reference` de l'editeur est supprime : les references visuelles ne sont
  plus affichees dans le workflow courant.
- La preview `Produit` utilise `AnimatedSprite2D.centered = false` et centre la texture
  de la frame courante explicitement dans le viewport.
- Le manifest doit declarer les etats legacy multi-direction du player (`attack_*`)
  tant qu'ils existent, sinon les specs exportees perdent leur taille cible.
