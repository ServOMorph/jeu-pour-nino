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
Phases 0 a 6 sont closes cote editeur ; la zone est revenue en maintenance.
Le player est migre a 100% en sheets et ses PNG legacy sont maintenant archives hors audit.
Les gisements disposent d'un set dedie branche dans `game/data/materials.json`.
Le Veilleur des Cendres est livre avec sprite principal, pose `pause` et projectile dedie.
La validation visuelle interactive en jeu et dans l'editeur reste a faire sur ces livrables.

## Decisions structurantes
- Pour les mobs, boss et objets gameplay, le workflow valide est : generation HD sur fond chroma-key, detourage local, puis resize exact a la taille runtime.
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
