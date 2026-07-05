# Signals — jeu   (MAJ 2026-07-05)

## Actions ouvertes
- [P1] Finir la dette bloquante Phase 0 : les 3 appels `Inventory` sont corrigés (migrés vers `RunState`) et le niveau se charge sans crash, mais la validation complète n'est pas faite.
  fait quand: `inventory.gd` supprimé ; 20 tests GUT verts ; run manuel complet (miner, crafter, tuer ennemis, battre boss, relancer) sans erreur console, `MetaState` conservé après relance.
  réf: `roadmap.md` section « Dette bloquante Phase 0 »
- [P2] Démarrer Phase 1 roadmap v3 : matériaux typés (materials: Dictionary dans RunState).
  fait quand: miner ajoute le bon matériau ; HUD reflète les quantités par type ; tests verts ; couverture ≥ 85 % sur le périmètre livré.
  réf: `roadmap.md` Phase 1, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/hud.gd`
- [P3] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like (hors `idle`, corrigé précédemment). (zone game_art)
  fait quand: run1, run2, jump et attack utilisent tous des sprites cohérents en taille validée en jeu (idle réglé à 14x24, cohérent avec run/jump).
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`, `game_art/backlog_art.md`
- [P3] Aligner le design document v3 sur le scope réduit du Miroir du Noyau (2 paramètres au lieu de 4) — décision utilisateur du 2026-07-02, pas encore répercutée dans le doc.
  fait quand: `docs/v3/CoreDive Challenge — Design Document v3.md` ne mentionne plus « boss vaincus » et « style de jeu » comme paramètres actifs du Miroir (ou les marque explicitement backlog post-v3).
  réf: `roadmap.md` Phase 9 et section « Backlog post-v3 », `docs/v3/CoreDive Challenge — Le Noyau et le Boss Final Adaptatif.md`

## Questions ouvertes

## Échéances

## Blocages

## Contexte chaud
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement
- sync.py (racine) copie game_art/ → game/ automatiquement via run_game.py ; exclut `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`
- `run_edit_game.py` (racine) : lance jeu (gauche) + éditeur (droite), plein écran partagé, pour comparaison visuelle — utilisé et validé cette session
- Aucun fichier `.import` n'existe sous `game/assets/sprites/` — toutes les textures y sont chargées en runtime (`Image.load_from_file`), jamais via `preload()` sur un chemin PNG direct
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START (joymap.gd)
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run
- `inventory.gd` toujours présent, plus référencé — suppression restante dans l'action P1
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`), plus plein écran
- `game_art/backlog_art.md` centralise les besoins d'assets par phase — à consulter en priorité lors des sessions game_art
- Roadmap réordonnée (2026-07-02) : mort/résurrection/cicatrices (Phases 5-6) désormais avant le contenu des biomes 2/3/4 (Phase 7, ex-Phase 5). Vérifier les numéros de phase avant de s'y référer.
- `roadmap.md` détaillée (2026-07-02, session 2) : chaque phase ancrée dans le code réel (fichiers, lignes, schémas JSON cibles). Phase 5 : conserver la scène biome en mémoire pendant l'Arène (pas de sérialisation complète).
- Piège Godot découvert 2026-07-05 : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé fait que le `SubViewport` interne se redimensionne à la taille du container au lieu de garder sa résolution fixe zoomée — toujours régler `stretch_shrink` en complément de `stretch=true` pour un zoom pixel-perfect.
- game_art Phase 2 (2.1 à 2.4) intégralement terminée et validée visuellement.

## Dernière session (2026-07-05 — Phase 2.3 game_art validée, bug de zoom éditeur corrigé)

# Session du 2026-07-05

## Décisions prises
- Phase 2.3 game_art (comparaison visuelle jeu/éditeur via `run_edit_game.py`) exécutée et validée par l'utilisateur : rendu et fps cohérents entre jeu et éditeur.

## Livrables produits ou modifiés
- `game_art/editeur/main.gd` : correctif `_set_zoom` — ajout de `stretch_shrink = int(z)` sur le `SubViewportContainer`.
- `game_art/roadmap_editeur.md` : Phase 2.3 cochée, bug documenté.
- `_contexte/signals.md` : action P3 Phase 2.3 clôturée, contexte chaud mis à jour.

## Hypothèses validées / invalidées
- VALIDE : le sprite semblait minuscule dans l'éditeur à cause d'un `SubViewport` qui se redimensionnait à la taille du container agrandi (zoom) au lieu de rester à sa résolution native zoomée — corrigé par `stretch_shrink`.

## Prochaine étape exacte
Finir la validation Phase 0 (GUT + run manuel intégral : miner, crafter, tuer ennemis, battre boss, relancer + vérifier `MetaState` conservé) puis supprimer `inventory.gd`. Ensuite attaquer Phase 1 (matériaux typés).

## Question bloquante pour la session suivante
Aucune
