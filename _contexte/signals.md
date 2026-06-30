# Signals — jeu   (MAJ 2026-06-30)

## Actions ouvertes
- [P1] Valider Phase 0 en jeu : lancer GUT + run complet dans Godot 4.5.
  fait quand: 20 tests GUT verts ; run de bout en bout sans erreur console.
  réf: `game/tests/`, `game/scripts/run_state.gd`, `game/scripts/save_manager.gd`
- [P2] Démarrer Phase 1 roadmap v3 : matériaux typés (materials: Dictionary dans RunState).
  fait quand: miner ajoute le bon matériau ; HUD reflète les quantités par type ; tests verts.
  réf: `roadmap.md` Phase 1, `game/scripts/run_state.gd`, `game/scripts/ore_node.gd`, `game/scripts/hud.gd`
- [P3] Refaire toutes les frames du player dans le nouveau standard visuel Terraria-like. (zone game_art)
  fait quand: idle, run1, run2, jump et attack utilisent tous des sprites cohérents en 40x56/48x56 validés en jeu.
  réf: `docs/process_generation_sprites.md`, `game_art/data/animations.json`, `game_art/assets/player/`

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
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run
- inventory.gd toujours présent mais plus référencé — peut être supprimé

## Dernière session (2026-06-30 — Phase 0 implémentée)

# Session du 2026-06-30

## Décisions prises
- Phase 0 roadmap v3 implémentée : RunState + MetaState + SaveManager + migration Inventory + GUT installé.
- roadmap.md converti en liste de coches (- [ ] / - [x]) pour suivi visuel.

## Livrables produits ou modifiés
- game/scripts/run_state.gd : créé (autoload RunState, remplace Inventory)
- game/scripts/meta_state.gd : créé (autoload MetaState, grimoire + PC)
- game/scripts/save_manager.gd : créé (autoload SaveManager, user://meta_state.json)
- game/scripts/player.gd : Inventory → RunState
- game/scripts/craft_menu.gd : Inventory → RunState
- game/scripts/hud.gd : Inventory → RunState
- game/scripts/level.gd : Inventory → RunState + save_meta() en fin de run
- game/project.godot : autoloads mis à jour (RunState, MetaState, SaveManager)
- game/addons/gut/ : GUT v9.7.0 installé
- game/.gut_editor_config.json : config GUT pointant vers res://tests/
- game/tests/test_run_state.gd : 8 tests
- game/tests/test_meta_state.gd : 9 tests
- game/tests/test_save_manager.gd : 3 tests
- roadmap.md : coches ajoutées + Phase 0 cochée

## Hypothèses validées / invalidées
- VALIDE : migration Inventory → RunState mécanique, sans casse de l'API existante
- EN ATTENTE : tests GUT à exécuter dans Godot (GUT non vérifié en jeu)
- EN ATTENTE : run complet à valider après migration

## Prochaine étape exacte
Ouvrir Godot 4.5, activer GUT (Project Settings → Plugins), lancer "Run All" dans le panneau GUT.
Valider un run complet (F5). Si tout est vert → commencer Phase 1 (matériaux typés).

## Question bloquante pour la session suivante
Aucune
