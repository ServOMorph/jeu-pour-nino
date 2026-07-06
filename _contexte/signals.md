# Signals — jeu   (MAJ 2026-07-06)

## Question bloquante

## Actions ouvertes
- [P2] Lancer le développement avec 2 agents séparés (jeu et game_art) en s'appuyant sur `questions.md` comme source d'arbitrage commune en cas de doute de conception.
  fait quand: les deux agents travaillent sans contradiction — `roadmap.md` (jeu) et `game_art/backlog_art.md` (game_art) sont cohérents entre eux et avec `questions.md`.
  réf: `questions.md` (racine), `roadmap.md`, `game_art/backlog_art.md`
- [P1] Clore proprement la Phase 1 roadmap v3 : le socle matériaux typés est branché et le gating de minage est désormais data-driven, mais il manque encore la validation manuelle complète du flux minage/craft/HUD/menu dev.
  fait quand: un run manuel complet valide minage/craft/HUD/menu dev ; les tests restent verts avec couverture ≥ 85 % sur le périmètre livré.
  réf: `roadmap.md` Phase 1, `questions.md` Q041/Q022/Q045, `game/data/materials.json`, `game/data/level.json`, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/craft_menu.gd`, `game/scripts/hud.gd`
- [P2] Point de vigilance Phase 3 : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P3] Produire un sprite distinct pour `minerai_abyssal` afin de rendre le test manuel tier 3 lisible.
  fait quand: `minerai_abyssal` n'utilise plus le placeholder cuivre et dispose d'un sprite dédié visible en jeu.
  réf: `game_art/backlog_art.md`, `game/data/materials.json`, `game/assets/sprites/objects/`
- [P3] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like (hors `idle`, corrigé précédemment). (zone game_art)
  fait quand: run1, run2, jump et attack utilisent tous des sprites cohérents avec la taille actuelle validée en jeu.
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`, `game_art/backlog_art.md`

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- `questions.md` (racine) : 77+1 questions de conception v3 tranchées le 2026-07-06 — source de vérité pour tout arbitrage de design ambigu. Consulter avant de trancher soi-même un point non couvert par `roadmap.md`.
- `roadmap.md` et les 4 docs `docs/v3/*.md` ont été mis à jour le 2026-07-06 pour intégrer ces décisions (section « Décisions verrouillées » en tête de roadmap, sections « Précisions v3.1 » en tête de chaque doc v3).
- `game_art/backlog_art.md` mis à jour en cohérence le 2026-07-06 — c'est le point de jonction entre l'agent jeu et l'agent game_art ; toute nouvelle décision de conception affectant le visuel doit y être répercutée.
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement
- sync.py (racine) copie game_art/ → game/ automatiquement via run_game.py ; exclut `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`
- `run_edit_game.py` (racine) : lance jeu (gauche) + éditeur (droite), plein écran partagé, pour comparaison visuelle
- Aucun fichier `.import` n'existe sous `game/assets/sprites/` — toutes les textures y sont chargées en runtime (`Image.load_from_file`), jamais via `preload()` sur un chemin PNG direct
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd) — nouveaux boutons à réserver pour arme à distance et consommable (Q016/Q019)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`) — cible finale plein écran par défaut (Q072), à régler en Phase 10
- `roadmap.md` détaillée : chaque phase ancrée dans le code réel (fichiers, lignes, schémas JSON cibles). Phase 5 : conserver la scène biome en mémoire pendant l'Arène (pas de sérialisation complète) ; Phase 6 : planchers durs obligatoires dans `scars.json` (Q026b).
- Piège Godot découvert 2026-07-05 : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé fait que le `SubViewport` interne se redimensionne à la taille du container au lieu de garder sa résolution fixe zoomée — toujours régler `stretch_shrink` en complément de `stretch=true` pour un zoom pixel-perfect.
- game_art Phase 2 (2.1 à 2.4) intégralement terminée et validée visuellement.
- Phase 1 entamée le 2026-07-06 : `materials.json` ajouté, `RunState` migré vers `materials`, HUD/craft/gisements branchés, `coins` supprimés du code de jeu.
- Vérifié le 2026-07-06 : GUT vert (`23/23`) et démarrage Godot headless OK ; la fermeture de Phase 1 reste bloquée par l'absence d'un run manuel complet de validation.
- Setup de test Phase 1 ajouté le 2026-07-06 : un minerai tier 2 (`fer`) et un tier 3 (`minerai_abyssal`) sont placés autour de l'atelier dans `level.json`.
- Visuel manquant identifié le 2026-07-06 : `minerai_abyssal` n'a pas encore de sprite dédié ; entrée ajoutée dans `game_art/backlog_art.md`.

## Dernière session (2026-07-06 — gating minage fermé, setup de test atelier)

# Session du 2026-07-06

## Décisions prises
- Le gating de minage Phase 1 est branché en data-driven via `weapons.json` et `RunState.get_pickaxe_tier()`.
- La Phase 1 n'est pas close : un setup de test atelier a été ajouté, mais la validation manuelle complète reste à faire.

## Livrables produits ou modifiés
- `game/data/weapons.json`, `game/scripts/run_state.gd`, `game/tests/test_run_state.gd` : tier de pioche data-driven branché et testé (`23/23` GUT).
- `game/data/level.json` : minerais `fer` et `minerai_abyssal` ajoutés autour de l'atelier pour test manuel Phase 1.
- `roadmap.md`, `_contexte/signals.md` : état Phase 1 mis à jour après fermeture du placeholder `get_pickaxe_tier() = 1`.
- `game_art/backlog_art.md` : sprite manquant `minerai_abyssal` ajouté au backlog art.

## Hypothèses validées / invalidées
- VALIDE : le tier de pioche est bien lu depuis les données gameplay ; GUT (`23/23`) et démarrage headless du jeu/niveau passent.
- EN ATTENTE : validation manuelle complète de la Phase 1, désormais testable côté gameplay mais encore limitée visuellement pour le tier 3.

## Prochaine étape exacte
Tester manuellement le flux Phase 1 depuis l'atelier : minage tier 2/tier 3, craft, HUD et menu dev.
Si le manque de lisibilité du tier 3 gêne encore, produire le sprite `minerai_abyssal` côté game_art avant clôture de Phase 1.

## Question bloquante pour la session suivante
Aucune
