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
La phase 5 reste ouverte, mais le set joueur de base (`idle`, `run`, `jump`, `fall`,
`attack`, `hurt`, `dead`) a ete produit en HD, redimensionne et synchronise vers `game/`.
Le principal reste ouvert hors tooling : valider visuellement ce set en jeu, puis
basculer le player vers un vrai format spritesheet complet.

## Decisions structurantes
- L'inspecteur doit rester utilisable en demi-ecran : panneau droit compact,
  controles empiles si necessaire, pas de dependance a un scroll horizontal.
- `player.run.fps` est valide a 8.1 depuis la cloture Phase 3.3 du 2026-07-05.
- Le manifest d'audit utilise un schema par etat, pas par entite, pour supporter
  des tailles differentes comme `player.attack` en `129x150`.
- Les regressions de la phase audit sont verifiees en headless via
  `test_audit.gd` et `test_audit_ui.gd`.
- La vue audit est portee par une `AcceptDialog` avec `Tree` trie par severite,
  cliquable et exportable, sans refonte de layout principal.
- La preview de reference resout les PNG de `assets/from_reference/` par convention de
  nommage et applique exactement le meme zoom que la preview principale.
- Les fiches `specs/<entity>.md` sont generees depuis `animations.json`, `manifest.json`
  et l'audit courant pour servir de brief art directement exploitable.
- Pour les petits sprites gameplay, le process valide est : reference visuelle,
  production directe a la taille finale sur grille, palette limitee, preview x8,
  puis validation. Une reduction d'image IA ne doit pas etre livree comme asset final.
- Workflow valide pour les sprites personnage depuis le test `player idle` :
  generation `image_gen` en source HD sur fond chroma-key, suppression locale du fond,
  redimensionnement exact a la taille cible, puis integration. Pour une animation,
  partir d'une frame maitre et deriver les autres frames plutot que regenerer toute
  la serie from scratch.
- Les sprites source du player doivent etre orientes vers la droite ; le flip du jeu
  reste standard et ne doit pas compenser une orientation source inverse.
- `player.attack.offset` reste a `[0, 0]` avec les assets 150 px ; si l'attaque
  touche le sol, corriger le sprite source avant de retoucher les offsets.
