# Signals — game_art

## Actions ouvertes

- [P1] Phase 2 : débugger rendu gris de l'éditeur Godot.
  fait quand: game_art/editeur/main.tscn se lance et affiche galerie + preview animée.
  réf: game_art/editeur/main.gd (UI créée programmatiquement dans _ready) — suspect : Control anchor ou ordre init.

## Blocages

## Dernière session

# Session du 2026-06-27

## Décisions prises
- Migration complète spritesheets reportée après éditeur fonctionnel (re-génération art via Codex).
- Phase 2 démarrée : UI éditeur créée programmatiquement dans main.gd (pas de tscn complexe).

## Livrables produits ou modifiés
- game/scripts/animation_driver.gd : étendu Phase 1 (sheet + AtlasTexture, rétro-compatible PNG)
- game_art/assets/player/player_run_sheet.png : spritesheet 28×24 créé
- game_art/data/animations.json : état run player migré vers format spritesheet
- game_art/editeur/animation_driver.gd : version éditeur avec _editor_path()
- game_art/editeur/main.gd : UI programmatique (galerie + preview 200×200 + toolbar zoom/playback)
- game_art/editeur/main.tscn : scène racine minimale

## Hypothèses validées / invalidées
- VALIDÉ : animation_driver.gd lit sheet+AtlasTexture, rendu run correct en jeu.
- EN ATTENTE : éditeur Godot — fenêtre s'ouvre mais reste grise, bug UI non résolu.

## Prochaine étape exacte
Ouvrir game_art/editeur/main.gd, diagnostiquer pourquoi _ready() ne rend pas l'UI
(piste : Control sans anchor_right/bottom = 1.0 dans la tscn, ou set_anchors_preset appelé avant add_child).

## Question bloquante pour la session suivante
Aucune
