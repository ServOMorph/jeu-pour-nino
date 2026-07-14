# Signals — jeu   (MAJ 2026-07-14)

## Question bloquante
Attribution des PC en cas d'abandon de run : j'ai retenu que QUITTER/RECOMMENCER depuis la pause comptent comme une fin de run ratée (PC ×0.5 crédités, sauvegarde). Non tranché par `questions.md`. Confirmer ou choisir « abandon = zéro PC ».

## Actions ouvertes
- [P1] Validation manuelle du jalon J1 (Phase 3) — non faite cette session. Parcours : titre → HUB (PV pleins, décor visible), stèle Grimoire, établi tier 1, portail biome1, miner/crafter/équiper, retour HUB via le portail « RETOUR HUB », vérifier conservation matériaux/équipement et PV pleins, re-entrer dans le biome, tuer le boss (écran « BOSS VAINCU » → HUB), ré-entrer et vérifier que le boss n'est plus là. Vérifier aussi les raccourcis dev du menu titre (HUB / BIOME DIRECT / ATELIER / TEST BOSS).
  fait quand: parcours complet joué sans anomalie, section correspondante ajoutée à `tests_manuels.md`, case « Validation en jeu » cochée dans `roadmap.md` Phase 3.
  réf: `roadmap.md` Phase 3, `game/scripts/game_flow.gd`, `game/scripts/hub.gd`, `python run_game.py`
- [P2] Démarrer la Phase 4 — génération procédurale du biome 1 (jalon J2), une fois J1 validé.
  fait quand: deux lancements du biome 1 produisent deux agencements différents et complétables ; `tests/test_biome_generator.gd` vert.
  réf: `roadmap.md` Phase 4
- [P2] Bumper `CHANGELOG.md` de la session Phase 2 : toujours en attente (le bump de cette session couvre la Phase 3, pas la clôture Phase 2).
  fait quand: `CHANGELOG.md` contient une entrée décrivant la clôture Phase 2 (barème PC, armes à distance, outils dev, défilement UI).
  réf: `CHANGELOG.md`, `git log`
- [P2] Triggers `Salle B1-B4` et `Porteur` (17 recettes non-starter restantes) non branchables : dépendent des phases 4, 7a-c, 8.
  fait quand: n/a — dépend du développement des phases 4/7a-c/8.
  réf: `game/scripts/recipe_catalog.gd` (`discover_by_trigger`), `game/data/recipes.json`
- [P3] Suivre l'avancement du pivot art via `game_art/backlog_art.md` (canal unique de handoff).
  fait quand: n/a — statut et priorité des items art vivent uniquement dans `backlog_art.md`.
  réf: `game_art/backlog_art.md`

## Questions ouvertes

## Échéances

## Blocages
*Aucun.*

## Contexte chaud
- `questions.md` (racine) : 77+1 questions de conception v3 tranchées le 2026-07-06 — source de vérité pour tout arbitrage de design ambigu.
- Godot 4.5 : `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`. GUT headless : `--headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` (49/49 verts au 2026-07-14). Lancement jeu : `python run_game.py`.
- `GameFlow` (autoload, `scripts/game_flow.gd`) : unique point d'entrée du flux de run. `start_run()` est le SEUL appel de `RunState.reset()` du projet — ne jamais le rappeler ailleurs. `enter_biome(id)` charge `res://data/biomes/<id>.json` via `next_biome_id`, `return_to_hub()`, `end_run(failed)` (calcul PC + `SaveManager.save_meta()`).
- `RunState` porte désormais `visited_biomes` et `defeated_bosses` (`mark_biome_visited`/`mark_boss_defeated`) : un biome revisité ne recompte pas son PC, un boss vaincu n'est plus spawné du run en cours.
- Scène de biome générique : `scenes/levels/biome.tscn` (ex-`biome1.tscn`) — le biome joué est déterminé par `GameFlow.next_biome_id`, pas par la scène.
- `hub_portal.gd` : script d'interaction générique (Area2D + prompt `interact`), utilisé pour les 4 portails du HUB, la stèle Grimoire et le portail de sortie de biome. Champ `locked` = « EN CONSTRUCTION ».
- Parallax biome 1 branché dans `level.gd` (`background.layers` de `biomes/biome1.json`, textures `game_art/assets/tiles/biome1_parallax_*.png`) — travail issu de la zone game_art, commité avec cette session pour cohérence du repo.
- Source de vérité sprites/animations : `game_art/assets/` + `game_art/data/animations.json` ; `game/assets/sprites/` est gitignoré et régénéré par sync.py (via `run_game.py`). Ne jamais y éditer directement.
- Manette : interact=JOY_BUTTON_Y, use_item=LEFT_SHOULDER, sprint=LEFT_STICK, pause_menu=START, attack=RIGHT_SHOULDER (`joymap.gd`). Le bouton `attack` sert aussi au tir si l'arme équipée est `ranged`. JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser.
- Règle absolue : toute valeur numérique gameplay dans `game/data/*.json`.
- Piège GDScript : un `const` de tableau non typé rend l'indexation `Variant` et casse l'inférence — toujours typer (`const X: Array[String] = [...]`).
- UI à liste scrollable (`craft_menu.gd`, `grimoire_menu.gd`) : pattern de fenêtre glissante à réutiliser pour toute nouvelle UI listant un nombre variable d'éléments.
- Outils dev (`Dev` autoload) : `dev_resources`, `infinite_hp`, `pc_infinite`, `no_enemies`, `one_shot` — lus/écrits à l'identique par `title.gd`, `pause_menu.gd`, `level.gd` et `hub.gd`. Toute nouvelle bascule dev doit suivre ce pattern.
- `tests_manuels.md` (racine) : sections 1-12 validées le 2026-07-12 (Phase 2). Aucune section Phase 3 encore écrite.

## Dernière session (2026-07-14 — Phase 3 livrée côté code : HUB, run multi-biomes)

## Décisions prises
- Le flux de run passe par un autoload `GameFlow` : `RunState.reset()` n'a plus lieu qu'au lancement d'un nouveau run, jamais à l'entrée d'un biome (Q001 respecté).
- Battre un boss de biome ne termine plus le run : écran bref « BOSS VAINCU » puis retour HUB ; le boss est marqué vaincu pour le run et n'est plus spawné.
- Fin de run = mort (écran de fin, PC ×0.5), ou abandon via pause (QUITTER/RECOMMENCER), traité comme un run raté pour ne pas perdre les PC accumulés — décision à confirmer (voir question bloquante).
- Les 3 biomes non implémentés sont présents au HUB en portails `locked` (« EN CONSTRUCTION ») plutôt qu'absents.
- Décor de HUB livré par game_art (`hub_decor.png`) intégré : entrée `backlog_art.md` passée `livre` → `integre`.

## Livrables produits ou modifiés
- `game/scripts/game_flow.gd` (nouveau, autoload) ; `game/project.godot` : autoload `GameFlow`.
- `game/scripts/hub.gd`, `game/scenes/levels/hub.tscn`, `game/data/hub.json`, `game/scripts/hub_portal.gd`, `game/scripts/biome_cleared.gd` (nouveaux).
- `game/scripts/level.gd` : biome paramétré par `GameFlow`, portail de sortie volontaire, boss conditionnel, transitions HUB.
- `game/scripts/run_state.gd` : `visited_biomes`/`defeated_bosses` + API. `game/scripts/player.gd` : `heal_full()`. `game/scripts/hud.gd` : boss optionnel. `game/scripts/end_screen.gd`, `game/scripts/title.gd` : transitions via `GameFlow`.
- `game/data/level.json` → `game/data/biomes/biome1.json` ; `game/scenes/levels/biome1.tscn` → `biome.tscn`.
- `game/tests/test_game_flow.gd` (9 tests) ; `roadmap.md`, `README.md`, `game_art/backlog_art.md` mis à jour.

## Hypothèses validées / invalidées
- VALIDE : 49/49 tests GUT verts ; boot headless de `hub.tscn` et `biome.tscn` sans erreur ni warning.
- EN ATTENTE : validation manuelle du jalon J1 — aucun parcours joué cette session.
- EN ATTENTE : arbitrage de l'attribution des PC sur abandon de run.

## Prochaine étape exacte
Lancer `python run_game.py` et jouer le parcours J1 complet (voir action P1), puis cocher la case « Validation en jeu » de la Phase 3 et écrire la section correspondante dans `tests_manuels.md`.

## Question bloquante pour la session suivante
Abandon de run (QUITTER/RECOMMENCER en pause) : PC ×0.5 comme un run raté (choix actuel) ou zéro PC ?
