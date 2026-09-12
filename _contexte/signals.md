# Signals — jeu   (MAJ 2026-09-13)

## Question bloquante
Attribution des PC en cas d'abandon de run : j'ai retenu que QUITTER/RECOMMENCER depuis la pause comptent comme une fin de run ratée (PC ×0.5 crédités, sauvegarde). Non tranché par `questions.md`. Confirmer ou choisir « abandon = zéro PC ».

## Actions ouvertes
- [P1] Validation manuelle du jalon J1 (Phase 3) — non faite. Parcours : titre → HUB (fond plein écran, 4 portails accessibles sur la ligne de marche, établi à droite), stèle Grimoire, établi tier 1, portail biome1, miner/crafter/équiper, retour HUB via le portail « RETOUR HUB », vérifier conservation matériaux/équipement et PV pleins, re-entrer dans le biome, tuer le boss (écran « BOSS VAINCU » → HUB), ré-entrer et vérifier que le boss n'est plus là. Vérifier aussi les raccourcis dev du menu titre (HUB / BIOME DIRECT / ATELIER / TEST BOSS).
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

## Contexte chaud
- `questions.md` (racine) : 77+1 questions de conception v3 tranchées le 2026-07-06 — source de vérité pour tout arbitrage de design ambigu.
- Godot 4.5 : `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`. GUT headless : `--headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit` (49/49 verts au 2026-07-14). Lancement jeu : `python run_game.py`.
- `GameFlow` (autoload, `scripts/game_flow.gd`) : unique point d'entrée du flux de run. `start_run()` est le SEUL appel de `RunState.reset()` du projet — ne jamais le rappeler ailleurs. `enter_biome(id)` charge `res://data/biomes/<id>.json` via `next_biome_id`, `return_to_hub()`, `end_run(failed)` (calcul PC + `SaveManager.save_meta()`).
- `RunState` porte désormais `visited_biomes` et `defeated_bosses` (`mark_biome_visited`/`mark_boss_defeated`) : un biome revisité ne recompte pas son PC, un boss vaincu n'est plus spawné du run en cours.
- Scène de biome générique : `scenes/levels/biome.tscn` (ex-`biome1.tscn`) — le biome joué est déterminé par `GameFlow.next_biome_id`, pas par la scène.
- HUB : `game_art/assets/tiles/hub_decor_portals_v2.png` remplit la fenêtre. Les 4 portails sont dans le fond, leurs zones d'interaction sont alignées sur la ligne de marche ; l'établi est à droite. `hub_portal.gd` n'affiche plus de rectangle ni nom de portail, seulement le prompt de proximité.
- Le boot headless de `hub.tscn` est vert au 2026-09-13 après synchronisation des assets.
- Parallax biome 1 branché dans `level.gd` (`background.layers` de `biomes/biome1.json`, textures `game_art/assets/tiles/biome1_parallax_*.png`) — travail issu de la zone game_art, commité avec cette session pour cohérence du repo.
- Source de vérité sprites/animations : `game_art/assets/` + `game_art/data/animations.json` ; `game/assets/sprites/` est gitignoré et régénéré par sync.py (via `run_game.py`). Ne jamais y éditer directement.
- Manette : interact=JOY_BUTTON_Y, use_item=LEFT_SHOULDER, sprint=LEFT_STICK, pause_menu=START, attack=RIGHT_SHOULDER (`joymap.gd`). Le bouton `attack` sert aussi au tir si l'arme équipée est `ranged`. JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser.
- Règle absolue : toute valeur numérique gameplay dans `game/data/*.json`.
- Piège GDScript : un `const` de tableau non typé rend l'indexation `Variant` et casse l'inférence — toujours typer (`const X: Array[String] = [...]`).
- UI à liste scrollable (`craft_menu.gd`, `grimoire_menu.gd`) : pattern de fenêtre glissante à réutiliser pour toute nouvelle UI listant un nombre variable d'éléments.
- Outils dev (`Dev` autoload) : `dev_resources`, `infinite_hp`, `pc_infinite`, `no_enemies`, `one_shot` — lus/écrits à l'identique par `title.gd`, `pause_menu.gd`, `level.gd` et `hub.gd`. Toute nouvelle bascule dev doit suivre ce pattern.
- `tests_manuels.md` (racine) : sections 1-12 validées le 2026-07-12 (Phase 2). Aucune section Phase 3 encore écrite.

## Dernière session (2026-09-13 — refonte visuelle et spatiale du HUB)

## Décisions prises
- Composition du HUB validée par l'utilisateur : quatre portes en bas de l'écran, personnage sur leur ligne d'accès et établi isolé à droite.
- Les noms et rectangles placeholder des portails sont retirés ; le décor contient désormais les portes.

## Livrables produits ou modifiés
- `game_art/assets/tiles/hub_decor_portals_v2.png` : fond plein écran généré avec quatre portails.
- `game/data/hub.json` : positions du sol, du joueur, des portails, du Grimoire et de l'établi alignées sur la nouvelle composition.
- `game/scripts/hub.gd` : géométrie de collision configurable sans masque visuel.
- `game/scripts/hub_portal.gd` : suppression des rectangles et noms placeholder.

## Hypothèses validées / invalidées
- VALIDE : boot headless de `hub.tscn` sans erreur après synchronisation des assets.
- EN ATTENTE : validation manuelle complète du jalon J1 et arbitrage des PC en cas d'abandon.

## Prochaine étape exacte
Lancer `python run_game.py`, vérifier visuellement la nouvelle disposition du HUB, puis jouer le parcours J1 complet. Cocher ensuite la validation Phase 3 et compléter `tests_manuels.md`.

## Question bloquante pour la session suivante
Abandon de run (QUITTER/RECOMMENCER en pause) : PC ×0.5 comme un run raté (choix actuel) ou zéro PC ?
