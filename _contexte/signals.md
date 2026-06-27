# Signals — jeu   (MAJ 2026-06-27)

## Actions ouvertes
- [P1] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like.
  fait quand: idle, run1, run2, jump et attack utilisent tous des sprites cohérents en 40x56/48x56 validés en jeu.
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`
- [P2] Étendre la logique d'équipement obsolète aux armures si plusieurs paliers sont ajoutés.
  fait quand: si plusieurs armures existent, les paliers dépassés disparaissent de l'établi.
  réf: `game/scripts/craft_menu.gd`, `game/data/recipes.json`, `game/data/armor.json`

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement
- sync.py (racine) copie game_art/ → game/ automatiquement via run.py
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé

## Dernière session (2026-06-27 — plein écran, clavier, pipeline sync)

# Session du 2026-06-27

## Décisions prises
- Affichage jeu : plein écran 1920×1080 (viewport pixel reste 480×270 ×4, nearest).
- Contrôles clavier complets ajoutés : flèches (move), Z (attack), E (interact), R (use_item), Shift (sprint), Echap (pause_menu).
- Périmètre zone jeu : lancement, affichage, contrôles. Sprites/animations = zone game_art.

## Livrables produits ou modifiés
- game/project.godot : plein écran 1920×1080 + bindings clavier complets
- run.py : appel sync() avant lancement Godot
- sync.py (racine) : synchronise game_art/ → game/ (créé, appartient zone jeu)

## Hypothèses validées / invalidées
- VALIDE : jeu lancé avec succès après modifications (plein écran + clavier)
- VALIDE : sync.py opérationnel (47 fichiers, parité game_art/ ↔ game/assets/sprites/)

## Prochaine étape exacte
Reprendre le chantier sprites player (zone game_art, Phase 1) : support spritesheets
dans animation_driver.gd, puis régénérer les frames player via Codex dans le standard 40×56.

## Question bloquante pour la session suivante
Aucune
