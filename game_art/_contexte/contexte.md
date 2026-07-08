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
Phases 0, 1, 2, 3 et 4 sont closes cote editeur ; la phase 5 reste ouverte.
Le player est maintenant migre a 100% en sheets cote editeur et cote jeu, sans fallback legacy dans `animations.json`.
Les tests headless `test_preview_center`, `test_specs_export`, `test_audit_ui` et `test_audit` passent.
Les anciens PNG player restent presents comme sources non referencees et polluent l'audit via des warnings globaux.
Boss, mobs et objets gameplay critiques restent livres ; validation visuelle interactive encore a faire.

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
- Les PNG player legacy sont conserves localement comme sources tant qu'aucune decision
  explicite de nettoyage ou d'exclusion d'audit n'a ete prise.
