# Signals — jeu   (MAJ 2026-07-12)

## Question bloquante
Aucune côté jeu.

## Actions ouvertes
- [P1] Démarrer la Phase 3 — HUB et sélection de biome. Point de vigilance : déplacer `RunState.reset()` de `level.gd._ready()` vers `title.gd._start_game()` — un run est multi-biomes, le reset ne doit avoir lieu qu'au lancement d'un nouveau run, pas à chaque entrée en biome.
  fait quand: HUB jouable, un aller-retour HUB↔biome en cours de run conserve matériaux/équipement/cicatrices ; test de non-régression dédié vert.
  réf: `roadmap.md` Phase 3, `questions.md` Q001
- [P2] Bumper `CHANGELOG.md` pour cette session (Phase 2 clôturée) : reporté car une édition concurrente côté `game_art` était en cours au moment du close (entrées v1.52/v1.53 non commitées).
  fait quand: `CHANGELOG.md` contient une entrée décrivant la clôture Phase 2 (barème PC, armes à distance, outils dev, défilement UI), ajoutée sans écraser le travail game_art.
  réf: voir `git log`/`git diff CHANGELOG.md` pour l'état au moment de la reprise
- [P2] Triggers `Salle B1-B4` et `Porteur` (17 recettes non-starter restantes) non branchables : dépendent de systèmes absents (biomes multiples, ennemis porteurs — phases 4, 7a-c, 8). À traiter quand ces phases seront développées, pas avant.
  fait quand: n/a — dépend du développement des phases 4/7a-c/8.
  réf: `game/scripts/recipe_catalog.gd` (`discover_by_trigger`), `game/data/recipes.json`
- [P3] Suivre l'avancement du pivot art via `game_art/backlog_art.md` (canal unique de handoff).
  fait quand: n/a — le statut et la priorité de ces items vivent uniquement dans `backlog_art.md`, pas ici.
  réf: `game_art/backlog_art.md`

## Questions ouvertes

## Échéances

## Blocages
*Aucun.*

## Contexte chaud
- `questions.md` (racine) : 77+1 questions de conception v3 tranchées le 2026-07-06 — source de vérité pour tout arbitrage de design ambigu.
- Ollama opérationnel sur cette machine — prêt pour délégation de tâches templated.
- Godot 4.5 disponible via `D:\tmp\godot45\Godot_v4.5-stable_win64.exe`.
- Source de vérité sprites/animations : `game_art/assets/` et `game_art/data/animations.json` — ne pas éditer `game/assets/sprites/` directement.
- sync.py (racine) copie game_art/ → game/ automatiquement via run_game.py ; exclut `from_reference`, `generated_raw`, `*.import`, `sprite_contact_sheet.png`, `sprite_generation_manifest.json`.
- Aucun fichier `.import` n'existe sous `game/assets/sprites/` — toutes les textures y sont chargées en runtime (`Image.load_from_file`), jamais via `preload()` sur un chemin PNG direct.
- Manette : interact=JOY_BUTTON_Y, use_item=JOY_BUTTON_LEFT_SHOULDER, sprint=JOY_BUTTON_LEFT_STICK, pause_menu=JOY_BUTTON_START, attack=JOY_BUTTON_RIGHT_SHOULDER (joymap.gd). Pas de bouton dédié pour l'arme à distance : le bouton `attack` sert au tir si l'arme équipée est de type `ranged` (décision explicite utilisateur, cf. `player.gd._physics_process`).
- Piège Godot : JOY_BUTTON_X = ui_up par défaut → ne pas l'utiliser pour action custom.
- Règle absolue : toute valeur numérique gameplay dans game/data/*.json — aucune constante hardcodée.
- Piège manette title.gd : _a_was doit être mis à jour EN TÊTE de _process avant tout return anticipé.
- GUT v9.7.0 installé dans game/addons/gut/ — activer via Project Settings → Plugins avant premier run. Vérification headless : `Godot_v4.5-stable_win64.exe --headless --path game -s addons/gut/gut_cmdln.gd -gdir=res://tests -gexit`. 40/40 tests verts (4 scripts) au 2026-07-12.
- `game/project.godot` : fenêtre en mode fenêtré (`window/size/mode=0`) — cible finale plein écran par défaut (Q072), à régler en Phase 10.
- Piège Godot découvert 2026-07-05 : `SubViewportContainer.stretch = true` sans `stretch_shrink` réglé fait que le `SubViewport` interne se redimensionne à la taille du container au lieu de garder sa résolution fixe zoomée.
- Piège GDScript découvert 2026-07-11 : un `const` de tableau non typé (`const X := [...]`) rend `X[i]` de type `Variant` — `var v := X[i]` échoue alors à l'inférence de type sous Godot 4.5 et casse la compilation du script entier (et de tout ce qui le précharge). Toujours typer les const tableaux utilisés pour de l'indexation (`const X: Array[String] = [...]`).
- Slots `weapon`/`armor`/`accessory`/`tool`/`consumable` gérés par `equipment_menu.gd` ; les recettes de slot `utility` (`pioche_renforcee`, `corde`, `etabli_portable`) ne sont pas équipables via cet écran — `pioche_renforcee` agit automatiquement dès qu'elle est possédée (tier de minage), `corde`/`etabli_portable` n'ont aucun effet en jeu implémenté à ce stade.
- Aucune recette starter n'a le slot `accessory` — le slot ACCESSOIRE reste normalement vide (`Aucun` seul choix) hors des 3 recettes débloquées par victoire boss.
- `tests_manuels.md` (racine) : validation manuelle complète (2026-07-12), toutes sections 1-12 OK sans anomalie (Phase 2 + armes distance + gain PC + outils dev).
- `RecipeCatalog.discover_by_trigger()` (`game/scripts/recipe_catalog.gd`) : appelé depuis `level.gd._on_boss_died()` — seul trigger de découverte de recette branché à ce jour (victoire boss). Pattern réutilisable pour brancher les futurs triggers salle/porteur.
- Outils dev (`Dev` autoload, `dev.gd`) : `dev_resources`, `infinite_hp`, `pc_infinite`, `no_enemies`, `one_shot` — source de vérité unique lue/écrite à l'identique par `title.gd` (menu titre) ET `pause_menu.gd`/`level.gd` (menu pause en jeu, effet immédiat). Toute nouvelle bascule dev doit suivre ce pattern pour rester synchronisée entre les deux menus.
- UI à liste scrollable (`craft_menu.gd`, `grimoire_menu.gd`) : pattern de fenêtre glissante (`VISIBLE_ROWS` fixe, `_window_start` recalculé sur la sélection) à réutiliser pour toute nouvelle UI listant un nombre variable d'éléments — ne jamais créer une ligne par élément total sans défilement (bug rencontré et corrigé cette session sur les deux écrans).
- `game/scripts/progression.gd` (`Progression.compute_skill_points`) : fonction pure du barème PC (Q044), lit `game/data/progression.json`. Compteurs de run dans `RunState.run_counters` (API `increment_counter`/`get_counter`/`set_counter_flag`/`get_counters`, reset avec `RunState.reset()`).

## Dernière session (2026-07-12 — Phase 2 clôturée : barème PC, armes à distance, outils dev unifiés)

## Décisions prises
- P1 restant de Phase 2 complété : barème/gain de PC (Q044), armes à distance (Q016), `tests/test_craft.gd`. Phase 2 reste techniquement ouverte dans `roadmap.md` (2 tâches mineures hors périmètre : retrait `_is_recipe_obsolete()`, test synergie cross-biome).
- Arme à distance sans bouton manette dédié : le bouton `attack` (mêlée) sert aussi au tir si l'arme équipée est de type `ranged` (revirement explicite utilisateur après un premier essai avec un bouton séparé).
- Outils dev étendus (`PC INFINI`, `SANS MOBS`, `ONE SHOT`, accès `GRIMOIRE`) et unifiés entre le menu titre et le menu pause via l'autoload `Dev` comme unique source de vérité, avec effet immédiat en jeu depuis la pause.
- Bug de recettes hors écran corrigé sur `craft_menu.gd` et `grimoire_menu.gd` via un pattern de liste à défilement (fenêtre glissante suivant la sélection).
- Bump `CHANGELOG.md` différé : édition concurrente `game_art` (v1.52/v1.53) non commitée au moment du close — ne pas écraser ce travail, à reprendre à la prochaine session une fois le repo stabilisé.

## Livrables produits ou modifiés
- `game/data/progression.json`, `game/scripts/progression.gd` : barème PC + fonction pure `compute_skill_points`.
- `game/scripts/run_state.gd`, `game/scripts/level.gd` : compteurs de run, gain de PC aux deux fins de run, affichage sur l'écran de fin (`end_screen.gd`).
- `game/data/weapons.json`, `game/scripts/player.gd`, `game/scripts/player_projectile.gd`, `game/scenes/player/player_projectile.tscn`, `game/scripts/audio.gd` : armes à distance jouables.
- `game/scripts/dev.gd`, `game/scripts/title.gd`, `game/scripts/pause_menu.gd` : outils dev étendus et unifiés (+ accès Grimoire en pause).
- `game/scripts/craft_menu.gd`, `game/scripts/grimoire_menu.gd` : défilement en fenêtre glissante.
- `game/data/level.json` : spawn `atelier` repositionné juste à gauche de l'établi.
- `game/tests/test_craft.gd` (12 tests), `game/tests/test_run_state.gd` (+3 tests) : 40/40 GUT verts.
- `roadmap.md`, `tests_manuels.md` : mis à jour (Phase 2 cases cochées, sections 10-12 validées).

## Hypothèses validées / invalidées
- VALIDE : 40/40 tests GUT verts et aucune erreur de script au boot headless après chaque étape de la session.
- VALIDE : toutes les sections de tests manuels (1-12) validées en jeu par l'utilisateur, aucune anomalie bloquante restante.
- EN ATTENTE : bump `CHANGELOG.md` de cette session, reporté à cause d'une édition concurrente game_art en cours.

## Prochaine étape exacte
Démarrer la Phase 3 (HUB et sélection de biome) — voir `roadmap.md` Phase 3. Reprendre aussi le bump `CHANGELOG.md` en attente.

## Question bloquante pour la session suivante
Aucune côté jeu.
